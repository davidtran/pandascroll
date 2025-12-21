import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

class LandingHeader extends StatelessWidget {
  const LandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo Section
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.bambooGreen, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bambooGreen.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text("🐼", style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                "Langrot",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pandaBlack,
                  fontFamily:
                      'Fredoka', // Ensuring usage of requested font family
                ),
              ),
            ],
          ),

          // Sign In Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.pandaBlack.withOpacity(0.1),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x19000000), // Black 10%
                  offset: Offset(0, 4), // Border-b-4 equivalent
                  blurRadius: 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  // TODO: Navigate to Sign In
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pandaBlack,
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
