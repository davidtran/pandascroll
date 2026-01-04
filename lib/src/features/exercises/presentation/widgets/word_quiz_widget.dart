import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/feed/domain/models/dictionary_model.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';

class WordQuizWidget extends StatefulWidget {
  final DictionaryModel currentWord;
  final List<DictionaryModel> allWords;
  final VoidCallback onCorrect;

  const WordQuizWidget({
    super.key,
    required this.currentWord,
    required this.allWords,
    required this.onCorrect,
  });

  @override
  State<WordQuizWidget> createState() => _WordQuizWidgetState();
}

class _WordQuizWidgetState extends State<WordQuizWidget> {
  late List<String> _options;
  bool _answered = false;
  bool _isCorrect = false;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _generateOptions();
  }

  @override
  void didUpdateWidget(covariant WordQuizWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWord != widget.currentWord) {
      _answered = false;
      _isCorrect = false;
      _selectedIndex = null;
      _generateOptions();
    }
  }

  void _generateOptions() {
    // Collect 3 incorrect definitions/translations
    final options = <String>[widget.currentWord.translation];
    final others =
        widget.allWords.where((w) => w.id != widget.currentWord.id).toList()
          ..shuffle();

    // Take up to 3 distactors
    for (var i = 0; i < min(3, others.length); i++) {
      options.add(others[i].translation);
    }

    // If not enough words, maybe duplicate? Or just show fewer.
    // Ideally we assume valid dataset.

    options.shuffle();
    _options = options;
  }

  void _handleOptionTap(int index, String option) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedIndex = index;
      _isCorrect = option == widget.currentWord.translation;
    });

    if (_isCorrect) {
      Future.delayed(const Duration(milliseconds: 1000), widget.onCorrect);
    } else {
      // Allow retry? Or auto move? Usually quiz lets you see the error.
      // For now, let's just wait a bit and move on or let them retry.
      // User requirement: "loop through". Usually means practice until done.
      // I'll auto move or let them tap "Next"?
      // Let's just auto-move for now or provide feedback.
      // Wait, if it's "Review", maybe we shouldn't punish hard.
      // I'll create a "Continue" button if wrong?
      // Or just delay and call onCorrect (which actually moves to next word) to not block flow?
      // Better: if wrong, showing Feedback, then valid response needed?
      // Let's stick to simplest: simple delay then next, or if rigorous, require correct answer.
      // For this "Fun" style: Green/Red flash, then next.
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
                "What does this mean?",
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.currentWord.word,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.pandaBlack,
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
                if (option == widget.currentWord.translation) {
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
                  text: option,
                  onPressed: () => _handleOptionTap(index, option),
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
