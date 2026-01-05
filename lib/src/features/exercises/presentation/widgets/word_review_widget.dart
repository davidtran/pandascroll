import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/exercise_progress_bar.dart';
import 'package:pandascroll/src/features/exercises/domain/models/exercise_dictionary_model.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/quiz/tts_player.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

class WordReviewWidget extends StatelessWidget {
  final ExerciseDictionaryModel word;
  final int index;
  final int total;
  final VoidCallback onNextWord;
  final VoidCallback onClose;
  final VoidCallback onIKnowThisWord;
  final VoidCallback onSkip;

  const WordReviewWidget({
    super.key,
    required this.word,
    required this.index,
    required this.total,
    required this.onNextWord,
    required this.onClose,
    required this.onIKnowThisWord,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
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

        // Card Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: .center,
                children: [
                  // Word Card
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      final inAnimation =
                          Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          );

                      final outAnimation =
                          Tween<Offset>(
                            begin: const Offset(-1.0, 0.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeIn,
                            ),
                          );

                      if (child.key == ValueKey(word.id)) {
                        return SlideTransition(
                          position: inAnimation,
                          child: child,
                        );
                      } else {
                        return SlideTransition(
                          position: outAnimation,
                          child: child,
                        );
                      }
                    },
                    child: Container(
                      key: ValueKey(word.id),
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.pandaBlack,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                              TtsPlayer(
                                id: word.id,
                                type: 'dictionary',
                                autoPlay: true,
                              ),
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
                onPressed: onNextWord,
              ),

              const SizedBox(height: 12),

              // I Know This Word
              PandaButton(
                text: 'I know this word',
                onPressed: onIKnowThisWord,
                backgroundColor: Colors.white,
                height: 50,
                borderColor: AppColors.pandaBlack,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: onSkip,
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
