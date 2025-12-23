import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../onboarding/presentation/views/preferences_view.dart';
import '../../../onboarding/presentation/widgets/landing_background_painter.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_hero.dart';
import '../widgets/login_welcome_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  Widget _buildSquareBtn(BuildContext context, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (icon == Icons.arrow_back) Navigator.of(context).pop();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textMain, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Listen for auth state changes to navigate
    ref.listen(authProvider, (previous, next) {
      if (next.value == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PreferencesView()),
          (route) => false,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.funBg,
      body: CustomPaint(
        painter: LandingBackgroundPainter(),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [_buildSquareBtn(context, Icons.arrow_back)],
                ),
              ),
              // Hero
              Expanded(child: const Center(child: LoginHero())),

              // Text & Buttons Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    const LoginWelcomeText(),
                    const SizedBox(height: 32),

                    if (authState.isLoading)
                      const CircularProgressIndicator(
                        color: AppColors.bambooGreen,
                      )
                    else ...[
                      if (Platform.isIOS)
                        PandaButton(
                          text: "Continue with Apple",
                          // Using Text widget as icon placeholder since no assets/fonts available yet.
                          leading: const FaIcon(
                            FontAwesomeIcons.apple,
                            color: Colors.white,
                          ),
                          backgroundColor: AppColors.pandaBlack,
                          textColor: Colors.white,
                          shadowColor: const Color.fromARGB(255, 67, 67, 67),
                          onPressed: () =>
                              ref.read(authProvider.notifier).signInWithApple(),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      PandaButton(
                        text: "Continue with Google",
                        leading: const FaIcon(
                          FontAwesomeIcons.google,
                          color: AppColors.pandaBlack,
                        ),
                        backgroundColor: Colors.white,
                        textColor: AppColors.pandaBlack,
                        onPressed: () =>
                            ref.read(authProvider.notifier).signInWithGoogle(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
