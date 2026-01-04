import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/feed/domain/models/dictionary_model.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/quiz/tts_player.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

class WordListenWidget extends StatefulWidget {
  final DictionaryModel currentWord;
  final List<DictionaryModel> allWords;
  final VoidCallback onCorrect;

  const WordListenWidget({
    super.key,
    required this.currentWord,
    required this.allWords,
    required this.onCorrect,
  });

  @override
  State<WordListenWidget> createState() => _WordListenWidgetState();
}

class _WordListenWidgetState extends State<WordListenWidget> {
  late List<DictionaryModel> _options;
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
    final options = <DictionaryModel>[widget.currentWord];
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
                          padding: const EdgeInsets.symmetric(
                            vertical: 50,
                            horizontal: 24,
                          ),
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
                          child: Center(
                            child: Transform.scale(
                              scale: 2.0,
                              child: TtsPlayer(
                                id: widget.currentWord.id,
                                type: 'dictionary',
                              ),
                            ),
                          ),
                        ),
                        // Top Label
                        Positioned(
                          top: -14,
                          child: Transform.rotate(
                            angle: -0.02,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
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
                                "WHAT DID YOU HEAR?",
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pandaBlack,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
}
