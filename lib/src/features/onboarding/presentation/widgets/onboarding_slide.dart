import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

class OnboardingSlide extends StatelessWidget {
  final IconData icon; // Using IconData for placeholder
  final String title;
  final String body;
  final Color? iconColor;

  const OnboardingSlide({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Icon Placeholder
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primaryBrand).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 100,
              color: iconColor ?? AppColors.primaryBrand,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Body
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
              height: 1.5,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
