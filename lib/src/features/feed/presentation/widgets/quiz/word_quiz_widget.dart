import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../domain/models/exercise_model.dart';

class WordQuizWidget extends StatefulWidget {
  final WordQuizData data;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const WordQuizWidget({
    super.key,
    required this.data,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<WordQuizWidget> createState() => _WordQuizWidgetState();
}

class _WordQuizWidgetState extends State<WordQuizWidget> {
  String? _selectedOption;
  bool _isAnswered = false;

  @override
  void didUpdateWidget(WordQuizWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.key != oldWidget.key) {
      setState(() {
        _selectedOption = null;
        _isAnswered = false;
      });
    }
  }

  void _handleOptionTap(String option) {
    if (_isAnswered) return;

    setState(() {
      _selectedOption = option;
      _isAnswered = true;
    });

    if (option == widget.data.correctMeaning) {
      widget.onCorrect();
    } else {
      widget.onWrong();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if audio is playing... User didn't ask for audio in WordQuiz but the image has "Tap to listen".
    // The previous implementation didn't have audio logic here, but the data model probably might not have it.
    // Wait, typical WordQuiz is text based. But Duolingo usually has audio.
    // The user image shows "Translate this word" + "Tap to listen".
    // I don't have audioUrl in WordQuizData readily available?
    // `ExerciseModel` wraps `data`. `WordQuizData` has `word`.
    // `QuizPanel` passes `audioUrl` to other widgets but NOT `WordQuizWidget` in `_buildExerciseContent`!
    // I should check `_buildExerciseContent` in `QuizPanel`.
    // It passes `onCorrect`.
    // I will stick to what I have, plus the design. I'll add a dummy button or functional if I can?
    // The user just said "improve the design".
    // I'll assume just visual update.

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section (Panda + Text)
          // Mimicking the uploaded image
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  const SizedBox(height: 60), // Space for Panda
                  Text(
                    "TRANSLATE THIS WORD",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.data.word,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      // Smaller than displayLarge
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Optional Pinyin if available, or just subtitle
                  // The image shows "(Ni hao)" below the word.
                  // My data model `WordQuizData` doesn't seem to have pinyin field, just `word` and `correctMeaning`.
                  // I'll skip pinyin for now.
                  const SizedBox(height: 24),

                  // Audio Button (Visual placeholder or simple interactivity?)
                  // Since I don't have audioUrl passed, I'll omit it or use a default if needed.
                  // Actually, avoiding broken features is better. I'll omit the "Tap to listen" unless I can access TTS.
                ],
              ),
              // Panda Image Header (Using Image asset or Decoration?)
              // The user prompt had "panda_hero_decoration.dart" in open files.
              // The image shows a full colored 3D panda. The code draws a CSS-like Panda.
              // I'll use the Asset image for the 3D panda if available, or just no panda for now to avoid errors?
              // The user prompt *showed* the 3D panda in the screenshot properly.
              // But the code provided for `PandaHeroDecoration` draws a simple panda.
              // I'll leave the mascot out to focus on the OPTIONS design which was the HTML code provided.
              // The HTML code wrapper was `<div class="flex flex-col gap-3 ...">`. This is mainly for options.
            ],
          ),

          const SizedBox(height: 32),

          // Options List
          Column(
            children: widget.data.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionCard(option, index),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String option, int index) {
    // Generate A, B, C, D labels
    final String label = String.fromCharCode(65 + index); // 65 is 'A'

    final isSelected = _selectedOption == option;
    final isCorrect = option == widget.data.correctMeaning;

    // Default Colors
    Color colorBg = Colors.white;
    Color colorBorder = Colors.grey.shade200;
    Color colorText = Colors.grey.shade700;
    Color colorLabelBg = Colors.grey.shade100;
    Color colorLabelText = Colors.grey.shade500;
    double elevation = 2;

    if (_isAnswered) {
      if (isSelected) {
        if (isCorrect) {
          // Selected Correct
          colorBg = Colors.green.shade50;
          colorBorder = Colors.green;
          colorText = Colors.green.shade900;
          colorLabelBg = Colors.green;
          colorLabelText = Colors.white;
        } else {
          // Selected Wrong
          colorBg = Colors.red.shade50;
          colorBorder = Colors.red;
          colorText = Colors.red.shade900;
          colorLabelBg = Colors.red;
          colorLabelText = Colors.white;
        }
      } else if (isCorrect) {
        // Unselected Correct (Reveal)
        colorBg = Colors.green.shade50;
        colorBorder = Colors.green;
        colorText = Colors.green.shade900;
        colorLabelBg = Colors.green;
        colorLabelText = Colors.white;
      }
    }

    return GestureDetector(
      onTap: () => _handleOptionTap(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorBorder, width: 2),
          boxShadow: [
            BoxShadow(
              color: !_isAnswered || !isSelected
                  ? Colors.black.withOpacity(0.05)
                  : colorBorder,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Label Box (A, B, C)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorLabelBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: colorLabelText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Option Text
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: colorText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
