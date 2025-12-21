import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../widgets/panda_button.dart';
import '../widgets/floating_badge.dart';
import '../widgets/joy_text.dart';
import '../widgets/landing_background_painter.dart';
import '../widgets/landing_header.dart';
import '../widgets/panda_hero_decoration.dart';
import '../widgets/phone_mockup.dart';
import 'onboarding_view.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.funBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          // Target ~50-55% of screen height for the hero section
          final heroHeight = screenHeight * 0.5;

          // Use a squarer aspect ratio (~3:4 or 4:5) instead of 9:16
          // Example: 280x380
          final ratio = 1;
          final phoneHeight = 350.0 * ratio;
          final phoneWidth = 280.0 * ratio;

          // Scale it down if screen is small
          final double scale = (heroHeight * 0.8) / phoneHeight;
          final double finalPhoneHeight = phoneHeight * scale;
          final double finalPhoneWidth = phoneWidth * scale;

          return CustomPaint(
            painter: LandingBackgroundPainter(),
            child: SafeArea(
              child: Column(
                children: [
                  const LandingHeader(),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: screenHeight * 0.02), // 2% spacing
                            // Hero Section
                            SizedBox(
                              height: heroHeight,
                              width: screenWidth,
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  // 1. Panda (Behind)
                                  Positioned(
                                    top:
                                        -finalPhoneHeight *
                                        0.05, // Adjust relative to phone size
                                    child: Transform.scale(
                                      scale:
                                          finalPhoneWidth /
                                          280, // Scale based on reference width
                                      child: const PandaHeroDecoration(),
                                    ),
                                  ),

                                  // 2. Phone (Center)
                                  PhoneMockup(
                                    width: finalPhoneWidth,
                                    height: finalPhoneHeight,
                                  ),

                                  // 3. Floating Badges
                                  Positioned(
                                    left:
                                        (screenWidth - finalPhoneWidth) / 2 -
                                        40,
                                    top: finalPhoneHeight * 0.2,
                                    child: Transform.scale(
                                      scale: 0.85,
                                      child: const FloatingBadge(
                                        emoji: "🇨🇳",
                                        text: "Chinese",
                                        backgroundColor: Color(0xFFFEE2E2),
                                        textColor: Color(0xFF991B1B),
                                        angle: -6,
                                        delay: Duration.zero,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right:
                                        (screenWidth - finalPhoneWidth) / 2 -
                                        40,
                                    bottom: finalPhoneHeight * 0.3,
                                    child: Transform.scale(
                                      scale: 0.85,
                                      child: const FloatingBadge(
                                        emoji: "🇬🇧",
                                        text: "English",
                                        backgroundColor: Color(0xFFDBEAFE),
                                        textColor: Color(0xFF1E40AF),
                                        angle: 6,
                                        delay: Duration(milliseconds: 1500),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "Learn with ",
                              style: TextStyle(
                                fontSize: 36, // text-4xl
                                fontWeight: FontWeight.w700,
                                color: AppColors.pandaBlack,
                                fontFamily: 'Fredoka',
                                height: 1.1,
                              ),
                            ),
                            const JoyText(),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          "Join our panda friend to master Chinese & English through fun videos!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4B5563), // Gray-600
                            fontFamily: 'Nunito',
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // CTA
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: PandaButton(
                            text: "Start Adventure",
                            icon: Icons.pets,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OnboardingView(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
