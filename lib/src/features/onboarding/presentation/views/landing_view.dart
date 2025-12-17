import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../widgets/fun_button.dart';
import '../widgets/hero_panda.dart';
import 'onboarding_view.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Hero Image
              const HeroPanda(size: 250),
              const SizedBox(height: AppSpacing.xl),
              
              // Headline
              Text(
                "Scroll Your Way\nto Fluency.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  height: 1.2,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Sub-text
              Text(
                "Turn your screen time into skill time.\nWatch short videos, fight bosses, and level up.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              
              // CTA Button
              SizedBox(
                width: double.infinity,
                child: FunButton(
                  text: "Start Scrolling 🐼",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OnboardingView()),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
