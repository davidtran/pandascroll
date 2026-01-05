import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// NO_CONTENT
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/exercises/domain/models/exercise_dictionary_model.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/question_widget.dart';
import 'package:pandascroll/src/features/feed/presentation/controllers/video_controller.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/sentence_audio_player.dart';

class WordListenWidget extends ConsumerStatefulWidget {
  final String videoId;
  final ExerciseDictionaryModel currentWord;
  final List<ExerciseDictionaryModel> allWords;
  final VoidCallback onCorrect;

  const WordListenWidget({
    super.key,
    required this.videoId,
    required this.currentWord,
    required this.allWords,
    required this.onCorrect,
  });

  @override
  ConsumerState<WordListenWidget> createState() => _WordListenWidgetState();
}

class _WordListenWidgetState extends ConsumerState<WordListenWidget> {
  late List<ExerciseDictionaryModel> _options;
  bool _answered = false;
  bool _isCorrect = false;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _generateOptions();
  }

  @override
  void didUpdateWidget(covariant WordListenWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWord != widget.currentWord) {
      _answered = false;
      _isCorrect = false;
      _selectedIndex = null;
      _generateOptions();
    }
  }

  void _generateOptions() {
    final options = <ExerciseDictionaryModel>[widget.currentWord];
    final others =
        widget.allWords.where((w) => w.id != widget.currentWord.id).toList()
          ..shuffle();

    for (var i = 0; i < min(3, others.length); i++) {
      options.add(others[i]);
    }

    options.shuffle();
    _options = options;
  }

  void _handleOptionTap(int index, String selectedWord) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedIndex = index;
      _isCorrect = selectedWord == widget.currentWord.word;
    });

    if (_isCorrect) {
      Future.delayed(const Duration(milliseconds: 1000), widget.onCorrect);
    } else {
      Future.delayed(const Duration(milliseconds: 1500), widget.onCorrect);
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
              QuestionWidget(
                title: "FILL IN THE GAP",
                child: Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: _buildSentenceSpans(widget.currentWord),
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        height: 1.4,
                        color: AppColors.pandaBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Audio Control
                    // Audio Control
                    Builder(
                      builder: (context) {
                        final videoState = ref.watch(videoFeedProvider);
                        final video = videoState.videos.firstWhere(
                          (v) => v.id == widget.videoId,
                          orElse: () => videoState.videos.first,
                        );
                        return SentenceAudioPlayer(
                          url: video.audioUrl,
                          start: widget.currentWord.sentence.start,
                          end: widget.currentWord.sentence.end,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  children: List.generate(_options.length, (index) {
                    final option = _options[index];
                    Color bgColor = Colors.white;
                    Color borderColor = AppColors.pandaBlack;

                    if (_answered) {
                      if (option.word == widget.currentWord.word) {
                        bgColor = AppColors.bambooGreen;
                        borderColor = AppColors.bambooDark;
                      } else if (index == _selectedIndex) {
                        bgColor = Colors.red[100]!;
                        borderColor = Colors.red;
                      }
                    }

                    final letter = String.fromCharCode(65 + index);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PandaButton(
                        text: option.word,
                        onPressed: () => _handleOptionTap(index, option.word),
                        backgroundColor: bgColor,
                        borderColor: borderColor,
                        height: 56,
                        textColor: AppColors.pandaBlack,
                        shadowOffset: const Offset(0, 2),
                        leading: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.pandaBlack,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            letter,
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.pandaBlack,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<InlineSpan> _buildSentenceSpans(ExerciseDictionaryModel wordModel) {
    // Basic implementation: split by word and replace the target word with ____
    // For a more robust solution, we might want the API to provide the gap position or specific text parts.
    // Here we'll do a simple case-insensitive replacement for now.
    final sentenceText = wordModel.sentence.text;
    final targetWord = wordModel.word;

    // Split keeping delimiters or just simple replace
    // Note: This simple replacement might fail if the word is a substring of another word.
    // Better to use RegExp with word boundaries

    // If exact match found, we construct spans.
    // If not found (e.g. conjugation diff), just show full sentence? Or fallback to showing ___ at the end?
    // User requirement: "replace the word with gap ___"

    // Let's try to match with Regex to handle case and keep surrounding text
    final matches = RegExp(
      r'\b' + RegExp.escape(targetWord) + r'\b',
      caseSensitive: false,
    ).allMatches(sentenceText);

    if (matches.isEmpty) {
      // Fallback: If word not found exactly (maybe morphology),
      // effectively we should just show the sentence with a gap hint?
      // But for now let's just show the sentence text as is if we can't find the word to mask.
      // OR better: Replace the word in the sentence provided by backend if it was pre-masked? No, backend sends full sentence.
      return [TextSpan(text: sentenceText)];
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (var match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: sentenceText.substring(lastEnd, match.start)));
      }

      // The Gap
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.funBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.pandaBlack, width: 1.5),
            ),
            child: Text(
              _answered && _isCorrect ? targetWord : "_____",
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.pandaBlack,
              ),
            ),
          ),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < sentenceText.length) {
      spans.add(TextSpan(text: sentenceText.substring(lastEnd)));
    }

    return spans;
  }
}
