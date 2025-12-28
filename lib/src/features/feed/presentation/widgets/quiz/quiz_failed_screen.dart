import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../onboarding/presentation/widgets/panda_button.dart';

class QuizFailedScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const QuizFailedScreen({
    super.key,
    required this.onRetry,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/broken_heart.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              "Out of Lives!",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "You ran out of hearts. Try again better next time!",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Retry Button (optional, maybe consumes energy? For now just restart logic)
            // But if energy is consumed on start, retry might fail if empty.
            // Let's simple "Continue" or "Close".
            // User said "try again better next time", implying close.
            PandaButton(
              onPressed: onClose,
              text: "Continue",
              backgroundColor: AppColors.primaryBrand,
            ),
          ],
        ),
      ),
    );
  }
}
