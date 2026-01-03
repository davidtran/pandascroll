import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pandascroll/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pandascroll/src/features/home/presentation/views/main_navigation_view.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/joy_text.dart';
import 'package:pandascroll/src/features/onboarding/presentation/widgets/panda_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../feed/presentation/views/feed_view.dart';
import '../../../onboarding/presentation/views/onboarding_view.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../profile/data/profile_repository.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Listen to auth state changes to navigate
    ref.listen(authProvider, (previous, next) async {
      if (next.value == true) {
        // Logged in successfully.
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return;

        bool hasProfile = false;

        // 1. Check if we have pending onboarding data to save
        final onboardingState = ref.read(onboardingProvider);
        if (onboardingState.nativeLanguage != null) {
          try {
            await ref
                .read(profileRepositoryProvider)
                .updateProfile(userId, onboardingState);
            hasProfile = true; // We just created/updated it
          } catch (e) {
            debugPrint("Failed to save profile on login: $e");
          }
        } else {
          // 2. No pending data, check if profile exists in DB
          try {
            final data = await Supabase.instance.client
                .from('profiles')
                .select()
                .eq('id', userId)
                .maybeSingle();
            if (data != null) {
              hasProfile = true;
            }
          } catch (e) {
            debugPrint("Error checking profile: $e");
          }
        }

        // 3. Navigate based on profile existence
        if (context.mounted) {
          if (hasProfile) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigationView(),
              ),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingView()),
              (route) => false,
            );
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF9FAFB), Color(0xFFF0FDF4)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: _buildSquareBtn(context, Icons.arrow_back),
                  ),
                  const Spacer(),
                  // Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),

                      child: Image.asset(
                        'assets/images/panda_login.png',
                        height: 200,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "welcome",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                      const SizedBox(width: 4),
                      JoyText(text: 'back!', fontSize: 36),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "sign in to sync your progress",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textMain.withOpacity(0.6),
                      fontFamily: 'Nunito',
                    ),
                  ),

                  const Spacer(),

                  if (authState.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    // Google Button
                    PandaButton(
                      text: "continue with Google",
                      leading: FaIcon(FontAwesomeIcons.google),
                      onPressed: () {
                        ref.read(authProvider.notifier).signInWithGoogle();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Apple Button
                    PandaButton(
                      text: "continue with Apple",
                      leading: FaIcon(FontAwesomeIcons.apple),
                      onPressed: () {
                        ref.read(authProvider.notifier).signInWithApple();
                      },
                      backgroundColor: Colors.white,
                      textColor: AppColors.pandaBlack,
                      borderColor: Colors.black,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}
