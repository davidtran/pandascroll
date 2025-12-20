import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../domain/models/exercise_model.dart';

class VideoUnderstandingWidget extends StatefulWidget {
  final VideoUnderstandingData data;
  final VoidCallback onCorrect;

  const VideoUnderstandingWidget({
    super.key,
    required this.data,
    required this.onCorrect,
  });

  @override
  State<VideoUnderstandingWidget> createState() =>
      _VideoUnderstandingWidgetState();
}

class _VideoUnderstandingWidgetState extends State<VideoUnderstandingWidget> {
  String? _selectedOption;
  bool _isAnswered = false;

  @override
  void didUpdateWidget(VideoUnderstandingWidget oldWidget) {
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

    if (option == widget.data.correctAnswer) {
      Future.delayed(const Duration(milliseconds: 1000), widget.onCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            widget.data.question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...widget.data.options.map((option) => _buildOption(option)),
      ],
    );
  }

  Widget _buildOption(String option) {
    final isSelected = _selectedOption == option;
    final isCorrect = option == widget.data.correctAnswer;

    Color backgroundColor = AppColors.background;
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
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Text(
          option,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
