import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/feed/domain/models/dictionary_model.dart';
import 'package:pandascroll/src/features/exercises/presentation/controllers/video_exercise_controller.dart';
import 'dart:ui';

import 'package:pandascroll/src/features/feed/presentation/widgets/quiz/tts_player.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';
import 'exercise_picker_widget.dart';
import 'exercise_review_widget.dart';
import 'word_quiz_widget.dart';
import 'word_speak_widget.dart';
import 'word_write_widget.dart';
import 'exercise_complete_widget.dart';

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
              return _buildReviewScreen(
                context,
                ref,
                state.words[state.currentIndex],
                state.currentIndex,
                state.words.length,
              );

            case ExerciseStage.quiz:
              return _buildGameWrapper(
                context,
                state,
                WordQuizWidget(
                  currentWord: state.words[state.currentIndex],
                  allWords: state.words,
                  onCorrect: () => ref
                      .read(videoExerciseProvider(videoId).notifier)
                      .nextWord(),
                ),
                () => ref
                    .read(videoExerciseProvider(videoId).notifier)
                    .nextWord(),
                ref, // Pass ref for close handler
              );

            case ExerciseStage.speak:
              return _buildGameWrapper(
                context,
                state,
                WordSpeakWidget(
                  currentWord: state.words[state.currentIndex],
                  onCorrect: () => ref
                      .read(videoExerciseProvider(videoId).notifier)
                      .nextWord(),
                ),
                () => ref
                    .read(videoExerciseProvider(videoId).notifier)
                    .nextWord(),
                ref,
              );

            case ExerciseStage.write:
              return _buildGameWrapper(
                context,
                state,
                WordWriteWidget(
                  currentWord: state.words[state.currentIndex],
                  onCorrect: () => ref
                      .read(videoExerciseProvider(videoId).notifier)
                      .nextWord(),
                ),
                () => ref
                    .read(videoExerciseProvider(videoId).notifier)
                    .nextWord(),
                ref,
              );

            case ExerciseStage.completed:
              return ExerciseCompleteWidget(
                onSemesterExercises: () {
                  ref
                      .read(videoExerciseProvider(videoId).notifier)
                      .startSentenceExercise();
                },
                onNextVideo: () => _handleClose(context, ref),
              );

            case ExerciseStage.sentenceReview:
              return ExerciseReviewWidget(
                onClose: () => _handleClose(context, ref),
              );
            default:
              return const SizedBox();
          }
        },
      ),
    );
  }

  // Wrapper to show progress bar and close button for games
  Widget _buildGameWrapper(
    BuildContext context,
    ExerciseState state,
    Widget child,
    VoidCallback onSkip,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                onPressed: () => _handleClose(context, ref),
              ),
              Expanded(
                child: Center(
                  child: ExerciseProgressBar(
                    currentIndex: state.currentIndex,
                    total: state.words.length,
                  ),
                ),
              ),
              // Balance out the close button
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(child: child),
        Padding(
          padding: const EdgeInsets.only(bottom: 24, top: 8),
          child: TextButton(
            onPressed: onSkip,
            child: const Text(
              "Skip",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
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
            "Finding more lessons...",
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

  Widget _buildReviewScreen(
    BuildContext context,
    WidgetRef ref,
    DictionaryModel word,
    int index,
    int total,
  ) {
    return Column(
      children: [
        // Header (Close + Progress)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                onPressed: () => _handleClose(context, ref),
              ),
              Row(
                children: List.generate(total > 4 ? 4 : total, (i) {
                  // Visual simplification for progress dots
                  bool isActive = i <= (index * 4 / total).floor();
                  return Container(
                    width: i == 0 ? 32 : 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.bambooGreen
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: isActive
                            ? AppColors.pandaBlack
                            : Colors.grey[300]!,
                      ),
                    ),
                  );
                }),
              ),
              Text(
                "${index + 1}/$total",
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),

        // Card Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: .center,
                children: [
                  // Avatar (Optional decorative)
                  // Skipping absolute positioned avatar from HTML effectively as we are inside a panel

                  // Word Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.pandaBlack, width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: .center,
                          children: [
                            Text(
                              word.word, // Native/Target? Ideally Target
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 32, // Scaled down slightly
                                fontWeight: FontWeight.w600,
                                color: AppColors.pandaBlack,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            TtsPlayer(id: word.id, type: 'dictionary'),
                          ],
                        ),

                        Text(
                          word.pronunciation,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          word.translation, // Or meaning
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.bambooDark,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        const Divider(height: 2, color: Colors.grey),
                        const SizedBox(height: 16),

                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: word
                                    .howToUse, // Assuming definition is here or translation
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom Actions
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
          child: Column(
            children: [
              // Next Word
              PandaButton(
                text: 'next word',
                icon: Icons.arrow_forward,
                height: 50,
                onPressed: () {
                  ref.read(videoExerciseProvider(videoId).notifier).nextWord();
                },
              ),

              const SizedBox(height: 12),

              // I Know This Word
              PandaButton(
                text: 'I know this word',
                onPressed: () {},
                backgroundColor: Colors.white,
                height: 50,
                borderColor: AppColors.pandaBlack,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => _handleClose(context, ref),
                child: const Text(
                  "Skip Review",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExerciseProgressBar extends StatelessWidget {
  final int currentIndex;
  final int total;

  const ExerciseProgressBar({
    super.key,
    required this.currentIndex,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final bool isActive = index == currentIndex;
        final bool isPast = index < currentIndex;

        // Visual states:
        // Active: Wide, Green, Black Border
        // Past: Small, Green, Black Border (Completed)
        // Future: Small, Gray, Gray Border

        final double width = isActive ? 32 : 12;
        final Color bgColor = (isActive || isPast)
            ? AppColors.bambooGreen
            : Colors.grey[200]!;
        final Color borderColor = (isActive || isPast)
            ? AppColors.pandaBlack
            : Colors.grey[300]!;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: width,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.pandaBlack.withOpacity(0.1),
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
