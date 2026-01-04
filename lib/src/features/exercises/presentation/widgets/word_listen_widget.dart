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
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Listen and choose the word",
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              // Large Audio Player
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.pandaBlack, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.pandaBlack,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  // Assuming TtsPlayer has logic to look good or we wrap it?
                  // TtsPlayer uses IconButton usually. We might need a bigger icon.
                  // The TtsPlayer widget is hardcoded to specific size?
                  // Let's modify TtsPlayer optionally or just use it as is?
                  // It renders an IconButton or similar.
                  // If TtsPlayer is just a button, we can center it.
                  // Ideally we want auto-play.
                  child: Transform.scale(
                    scale: 2.0,
                    child: TtsPlayer(
                      id: widget.currentWord.id,
                      type: 'dictionary',
                      // TODO: Pass autoPlay if available, or just rely on user tap
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PandaButton(
                  text: option.word,
                  onPressed: () => _handleOptionTap(index, option.word),
                  backgroundColor: bgColor,
                  borderColor: borderColor,
                  height: 56,
                  textColor: AppColors.pandaBlack,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
