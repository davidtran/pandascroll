import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/speaker_button.dart';
import 'package:pandascroll/src/features/feed/domain/models/dictionary_model.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/quiz/quiz_feedback_sheet.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/quiz/tts_player.dart';

class WordSpeakWidget extends StatefulWidget {
  final DictionaryModel currentWord;
  final VoidCallback onCorrect;

  const WordSpeakWidget({
    super.key,
    required this.currentWord,
    required this.onCorrect,
  });

  @override
  State<WordSpeakWidget> createState() => _WordSpeakWidgetState();
}

class _WordSpeakWidgetState extends State<WordSpeakWidget> {
  void _handleScore(double score) {
    final isSuccess = score > 0.5;

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => QuizFeedbackSheet(
          isCorrect: isSuccess,
          correctAnswer: widget.currentWord.word,
          onNext: () {
            Navigator.pop(context);
            widget.onCorrect();
          },
          onRetry: () {
            Navigator.pop(context);
            // Retry logic is now handled internally by SpeakerButton resetting state on next tap
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

        if (child.key == ValueKey(widget.currentWord.id)) {
          return SlideTransition(position: inAnimation, child: child);
        } else {
          return SlideTransition(position: outAnimation, child: child);
        }
      },
      child: Center(
        key: ValueKey(widget.currentWord.id),
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
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Main Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.funBg,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.pandaBlack,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.pandaBlack,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.pandaBlack,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: TtsPlayer(
                                        id: widget.currentWord.id,
                                        type: 'dictionary',
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      widget.currentWord.word,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: 40,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.pandaBlack,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '"${widget.currentWord.pronunciation}"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: 64,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.currentWord.translation,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.bambooDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Top Label
                        Positioned(
                          top: -14,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Transform.rotate(
                              angle: 0.05,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.pandaBlack,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Read this loud!',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.pandaBlack,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // Speaker Button (Smart)
                    SpeakerButton(
                      targetWord: widget.currentWord.word,
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
