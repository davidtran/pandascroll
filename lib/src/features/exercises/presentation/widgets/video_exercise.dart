import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/exercises/presentation/controllers/video_exercise_controller.dart';
import 'package:pandascroll/src/features/feed/presentation/controllers/video_controller.dart';
import 'dart:ui';

import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';
import 'exercise_picker_widget.dart';
import 'exercise_complete_widget.dart';
import 'word_review_widget.dart';
import 'sentence_review_widget.dart';
import 'word_game_widget.dart';

class VideoExercise extends ConsumerWidget {
  final String videoId;
  final VoidCallback onClose;

  const VideoExercise({
    super.key,
    required this.videoId,
    required this.onClose,
  });

  void _handleClose(BuildContext context, WidgetRef ref) {
    final state = ref.read(videoExerciseProvider(videoId)).asData?.value;
    if (state == null ||
        state.stage == ExerciseStage.picker ||
        state.stage == ExerciseStage.completed) {
      ref.invalidate(videoExerciseProvider(videoId));
      onClose();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.pandaBlack, width: 3),
            boxShadow: const [
              BoxShadow(
                color: AppColors.pandaBlack,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Quit Exercise?",
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pandaBlack,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "You're making great progress! Are you sure you want to stop now?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PandaButton(
                      text: "Keep Going",
                      onPressed: () => Navigator.pop(context),
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PandaButton(
                      text: "Quit",
                      onPressed: () {
                        Navigator.pop(context);
                        ref.invalidate(videoExerciseProvider(videoId));
                        onClose();
                      },
                      backgroundColor: Colors.white,
                      borderColor: Colors.red,
                      textColor: Colors.red,
                      height: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(videoExerciseProvider(videoId));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: exerciseAsync.when(
        loading: () => _buildLoadingState(context),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          switch (state.stage) {
            case ExerciseStage.picker:
              return ExercisePickerWidget(
                onWordExerciseTap: () {
                  ref
                      .read(videoExerciseProvider(videoId).notifier)
                      .startWordExercise();
                },
                onSentenceExerciseTap: () {
                  ref
                      .read(videoExerciseProvider(videoId).notifier)
                      .startSentenceExercise();
                },
                onMaybeLaterTap: () => _handleClose(context, ref),
              );
            case ExerciseStage.loading:
              return _buildLoadingState(context);

            case ExerciseStage.review:
              if (state.words.isEmpty)
                return const Center(child: Text("No words!"));
              return WordReviewWidget(
                word: state.words[state.currentIndex],
                index: state.currentIndex,
                total: state.words.length,
                onNextWord: () {
                  ref.read(videoExerciseProvider(videoId).notifier).nextWord();
                },
                onClose: () => _handleClose(context, ref),
                onSkip: () => ref
                    .read(videoExerciseProvider(videoId).notifier)
                    .skipReview(),
                onIKnowThisWord: () async {
                  final videos = ref.read(videoFeedProvider).videos;
                  final video = videos.firstWhere((v) => v.id == videoId);
                  final word = state.words[state.currentIndex].word;

                  await ref
                      .read(videoExerciseProvider(videoId).notifier)
                      .markWordAsKnown(word, video.language);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Word marked as known. It won't appear in future exercises.",
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor: Colors.amberAccent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            case ExerciseStage.listen:
            case ExerciseStage.quiz:
            case ExerciseStage.speak:
            case ExerciseStage.write:
              return WordGameWidget(
                videoId: videoId,
                state: state,
                onClose: () => _handleClose(context, ref),
                onNext: () => ref
                    .read(videoExerciseProvider(videoId).notifier)
                    .nextWord(),
                onSkip: () => ref
                    .read(videoExerciseProvider(videoId).notifier)
                    .nextWord(),
              );

            case ExerciseStage.completed:
              // Collect learned items for animation
              final learnedItems = <String>[];
              if (state.words.isNotEmpty) {
                learnedItems.addAll(state.words.map((e) => e.word));
              } else if (state.sentences.isNotEmpty) {
                // For sentences, just use "Sentence 1", "Sentence 2" or short snippet?
                // The prompt says "sentence and words that user have learn".
                // Full sentence might be too long for the bubble.
                // Let's use the full text but maybe ellipsized by the widget if needed.
                // Or "Sentence #1" etc. User wants "words / sentence".
                learnedItems.addAll(state.sentences.map((e) => e.text));
              }

              return ExerciseCompleteWidget(
                onSemesterExercises: () {
                  ref
                      .read(videoExerciseProvider(videoId).notifier)
                      .startSentenceExercise();
                },
                onNextVideo: () => _handleClose(context, ref),
                correctCount: 10,
                videoId: videoId,
                learnedItems: learnedItems,
              );

            case ExerciseStage.sentenceReview:
              if (state.sentences.isEmpty) {
                return const Center(child: Text("No sentences loaded!"));
              }
              return SentenceReviewWidget(
                videoId: videoId,
                sentence: state.sentences[state.currentIndex],
                index: state.currentIndex,
                total: state.sentences.length,
                onNext: () => ref
                    .read(videoExerciseProvider(videoId).notifier)
                    .nextWord(),
                onClose: () => _handleClose(context, ref),
              );
            case ExerciseStage
                .sentenceScramble: // [NEW] sentence exercise logic
            case ExerciseStage.sentenceSpeak:
            case ExerciseStage.sentenceDictation:
              if (state.sentences.isEmpty) {
                return const Center(child: Text("No sentences loaded!"));
              }
              return WordGameWidget(
                videoId: videoId,
                state: state,
                onClose: () => _handleClose(context, ref),
                onNext: () => ref
                    .read(videoExerciseProvider(videoId).notifier)
                    .nextWord(),
                onSkip: () => ref
                    .read(videoExerciseProvider(videoId).notifier)
                    .nextWord(),
              );
          }
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bambooDark, width: 4),
            ),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: CircularProgressIndicator(
                color: AppColors.bambooDark,
                strokeWidth: 4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Please wait...",
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.pandaBlack,
            ),
          ),
        ],
      ),
    );
  }
}
