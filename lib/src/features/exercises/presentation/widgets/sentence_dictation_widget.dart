import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/exercises/domain/models/sentence_exercise_model.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/question_widget.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/sentence_audio_player.dart';
import 'package:pandascroll/src/features/feed/presentation/controllers/video_controller.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/quiz/quiz_feedback_sheet.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

class SentenceDictationWidget extends ConsumerStatefulWidget {
  final String videoId;
  final SentenceExerciseModel sentence;
  final VoidCallback onCorrect;

  const SentenceDictationWidget({
    super.key,
    required this.videoId,
    required this.sentence,
    required this.onCorrect,
  });

  @override
  ConsumerState<SentenceDictationWidget> createState() =>
      _SentenceDictationWidgetState();
}

class _SentenceDictationWidgetState
    extends ConsumerState<SentenceDictationWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void didUpdateWidget(covariant SentenceDictationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sentence != oldWidget.sentence) {
      _controller.clear();
    }
  }

  void _checkAnswer() {
    final userInput = _normalize(_controller.text);
    final original = _normalize(widget.sentence.text);

    final similarity = _calculateSimilarity(userInput, original);
    final isSuccess = similarity >= 0.9;

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

  String _normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize spaces
  }

  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final distance = _levenshtein(s1, s2);
    final maxLength = max(s1.length, s2.length);
    return 1.0 - (distance / maxLength);
  }

  int _levenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        int cost = (s1.codeUnitAt(i) == s2.codeUnitAt(j)) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[s2.length];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  title: "Dictation",
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final videoState = ref.watch(videoFeedProvider);
                              final video = videoState.videos.firstWhere(
                                (v) => v.id == widget.videoId,
                                orElse: () => videoState.videos.first,
                              );

                              return SentenceAudioPlayer(
                                url: video.audioUrl,
                                start: widget.sentence.start,
                                end: widget.sentence.end,
                                autoPlay: true,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                const SizedBox(height: 32),
                const Text(
                  "Type what you hear",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.pandaBlack, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.pandaBlack,
                        offset: Offset(2, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: 3,
                    minLines: 1,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.pandaBlack,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type sentence here...",
                      hintStyle: TextStyle(color: Colors.black26),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                PandaButton(
                  text: 'Check Answer',
                  onPressed: _checkAnswer,
                  height: 56,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
