import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../domain/models/exercise_model.dart';

class WordQuizWidget extends StatefulWidget {
  final WordQuizData data;
  final VoidCallback onCorrect;

  const WordQuizWidget({
    super.key,
    required this.data,
    required this.onCorrect,
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
    if (widget.data != oldWidget.data) {
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
      Future.delayed(const Duration(milliseconds: 1000), widget.onCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.data.word,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Options Grid (Column of Rows)
        ...List.generate((widget.data.options.length / 2).ceil(), (rowIndex) {
          final startIndex = rowIndex * 2;
          final endIndex = startIndex + 2;
          final rowOptions = widget.data.options.sublist(
            startIndex,
            endIndex > widget.data.options.length
                ? widget.data.options.length
                : endIndex,
          );

          final rowWidgets = rowOptions.map((option) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: AspectRatio(
                  aspectRatio: 2.0,
                  child: _buildOption(option),
                ),
              ),
            );
          }).toList();

          // If row has only 1 item, add an empty Expanded to keep grid alignment
          if (rowWidgets.length < 2) {
            rowWidgets.add(const Expanded(child: SizedBox()));
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(children: rowWidgets),
          );
        }),
      ],
    );
  }

  Widget _buildOption(String option) {
    final isSelected = _selectedOption == option;
    final isCorrect = option == widget.data.correctMeaning;

    Color backgroundColor = Colors.white; // Default to white like other widgets
    Color borderColor = Colors.grey.shade200;
    Color textColor = AppColors.textMain;

    if (_isAnswered) {
      if (isSelected) {
        if (isCorrect) {
          backgroundColor = Colors.green.shade100;
          borderColor = Colors.green;
          textColor = Colors.green.shade900;
        } else {
          backgroundColor = Colors.red.shade100;
          borderColor = Colors.red;
          textColor = Colors.red.shade900;
        }
      } else if (isCorrect) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
      }
    }

    return GestureDetector(
      onTap: () => _handleOptionTap(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: borderColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          option,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
