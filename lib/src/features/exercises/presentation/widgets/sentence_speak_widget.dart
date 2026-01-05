import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/exercises/domain/models/sentence_exercise_model.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/question_widget.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/sentence_audio_player.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/speaker_button.dart';
import 'package:pandascroll/src/features/feed/presentation/controllers/video_controller.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/quiz/quiz_feedback_sheet.dart';

class SentenceSpeakWidget extends ConsumerStatefulWidget {
  final String videoId;
  final SentenceExerciseModel sentence;
  final VoidCallback onCorrect;

  const SentenceSpeakWidget({
    super.key,
    required this.videoId,
    required this.sentence,
    required this.onCorrect,
  });

  @override
  ConsumerState<SentenceSpeakWidget> createState() =>
      _SentenceSpeakWidgetState();
}

class _SentenceSpeakWidgetState extends ConsumerState<SentenceSpeakWidget> {
  void _handleScore(double score) {
    final isSuccess = score > 0.5;

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => QuizFeedbackSheet(
          isCorrect: isSuccess,
          correctAnswer: widget.sentence.text,
          onNext: () {
            Navigator.pop(context);
            if (isSuccess) {
              widget.onCorrect();
            }
          },
          onRetry: () {
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        final inAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation);

        final outAnimation = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(animation);

        if (child.key == ValueKey(widget.sentence.text)) {
          return SlideTransition(position: inAnimation, child: child);
        } else {
          return SlideTransition(position: outAnimation, child: child);
        }
      },
      child: Center(
        key: ValueKey(widget.sentence.text),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QuestionWidget(
                      title: "Read this aloud!",
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Optional: Audio Player for reference?
                              Consumer(
                                builder: (context, ref, child) {
                                  final videoState = ref.watch(
                                    videoFeedProvider,
                                  );
                                  final video = videoState.videos.firstWhere(
                                    (v) => v.id == widget.videoId,
                                    orElse: () => videoState.videos.first,
                                  );

                                  return SentenceAudioPlayer(
                                    url: video.audioUrl,
                                    start: widget.sentence.start,
                                    end: widget.sentence.end,
                                    autoPlay:
                                        true, // Don't auto-play here, let user choose
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            widget.sentence.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize:
                                  24, // Slightly smaller than word but large enough
                              fontWeight: FontWeight.w600,
                              color: AppColors.pandaBlack,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            widget.sentence.translation,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.bambooDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Speaker Button (Smart)
                    SpeakerButton(
                      targetWord: widget.sentence.text,
                      onScored: _handleScore,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
