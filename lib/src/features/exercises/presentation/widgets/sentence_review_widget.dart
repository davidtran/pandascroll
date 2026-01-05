import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/exercises/domain/models/sentence_exercise_model.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/exercise_progress_bar.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/question_widget.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/sentence_audio_player.dart';
import 'package:pandascroll/src/features/feed/presentation/controllers/video_controller.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

class SentenceReviewWidget extends ConsumerWidget {
  final SentenceExerciseModel sentence;
  final String videoId;
  final int index;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onClose;

  const SentenceReviewWidget({
    super.key,
    required this.sentence,
    required this.videoId,
    required this.index,
    required this.total,
    required this.onNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                onPressed: onClose,
              ),
              ExerciseProgressBar(currentIndex: index, total: total),
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

        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: QuestionWidget(
                title: "REVIEW SENTENCE",
                child: Column(
                  children: [
                    // Audio Player
                    Consumer(
                      builder: (context, ref, child) {
                        final videoState = ref.watch(videoFeedProvider);
                        final video = videoState.videos.firstWhere(
                          (v) => v.id == videoId,
                          orElse: () => videoState.videos.first,
                        );

                        return SentenceAudioPlayer(
                          url: video.audioUrl,
                          start: sentence.start,
                          end: sentence.end,
                          autoPlay: true,
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sentence Text
                    Text(
                      sentence.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pandaBlack,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    const Divider(color: Colors.grey, height: 1),
                    const SizedBox(height: 16),

                    // Translation
                    Text(
                      sentence.translation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom Actions
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: PandaButton(
            text: 'next sentence',
            icon: Icons.arrow_forward,
            height: 56,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }
}
