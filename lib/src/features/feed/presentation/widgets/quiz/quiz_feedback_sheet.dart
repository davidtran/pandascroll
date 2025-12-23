import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class QuizFeedbackSheet extends StatelessWidget {
  final bool isCorrect;
  final VoidCallback onNext;
  final VoidCallback? onRetry;
  final String? correctAnswer;
  final String? audioUrl; // Can be used to play audio if needed

  const QuizFeedbackSheet({
    super.key,
    required this.isCorrect,
    required this.onNext,
    this.onRetry,
    this.correctAnswer,
    this.audioUrl,
  });

  static const Color _surfaceDark = Color(0xFF1C2A33);
  static const Color _backgroundDark = Color(0xFF101C22);

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isCorrect
        ? AppColors.bambooGreen
        : Colors.redAccent;
    final String title = isCorrect ? "Great Job!" : "Try Again";
    final String message = isCorrect
        ? "You formed the sentence correctly."
        : "That's not quite right.";

    // Icon for the button
    final IconData btnIcon = isCorrect
        ? Icons.arrow_forward_rounded
        : Icons.refresh_rounded;
    final String btnText = isCorrect ? "Next" : "Retry";
    final VoidCallback? btnAction = isCorrect ? onNext : onRetry;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24).copyWith(bottom: 40),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 20, // ~text-3xl
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Fredoka',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 16, // ~font-medium
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Action Button
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: isCorrect
                  ? [
                      BoxShadow(
                        color: AppColors.bambooDark,
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: btnAction,
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          btnText,
                          style: const TextStyle(
                            color: _surfaceDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(btnIcon, color: _surfaceDark, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
