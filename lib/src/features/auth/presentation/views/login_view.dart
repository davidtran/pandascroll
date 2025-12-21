import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../onboarding/presentation/views/preferences_view.dart';
import '../controllers/auth_controller.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo / Branding
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text("🐼", style: TextStyle(fontSize: 64)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                "Welcome to PandaScroll",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Learn languages the fun way!",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textLight),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              if (authState.isLoading)
                const CircularProgressIndicator(color: AppColors.primaryBrand)
              else ...[
                // Google Button
                _SocialLoginButton(
                  text: "Continue with Google",
                  icon: "🇬", // Placeholder for Google Icon
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  onPressed: () =>
                      ref.read(authProvider.notifier).signInWithGoogle(),
                ),
                const SizedBox(height: AppSpacing.md),

                // Apple Button
                _SocialLoginButton(
                  text: "Continue with Apple",
                  icon: "",
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  onPressed: () =>
                      ref.read(authProvider.notifier).signInWithApple(),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String text;
  final String icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
            side: backgroundColor == Colors.white
                ? const BorderSide(color: Color(0xFFE0E0E0))
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: 24, color: textColor)),
            const SizedBox(width: AppSpacing.md),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
