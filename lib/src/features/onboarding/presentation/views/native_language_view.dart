import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/constants/language_constants.dart';
import '../providers/onboarding_provider.dart';
import 'target_language_view.dart';
import '../widgets/panda_button.dart';
import '../widgets/language_selector_widget.dart';

class NativeLanguageView extends ConsumerWidget {
  const NativeLanguageView({super.key});

  void _onContinue(BuildContext context, WidgetRef ref) {
    final selectedLangCode = ref.read(onboardingProvider).nativeLanguage;
    if (selectedLangCode != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TargetLanguageView()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color creamBg = Color(0xFFFEFDF5);
    const Color bgLight = Color(0xFFF0FDF4); // bg-background-light

    const Color textMain = Color(0xFF1E293B); // text-main

    final currentCode = ref.watch(onboardingProvider).nativeLanguage;

    return Scaffold(
      backgroundColor: creamBg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Title Section with Panda
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/panda.png', height: 64),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "which language?",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: textMain,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "select your native language so langrot can help you!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),

                // Language List
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    child: Column(
                      children: [
                        // Suggested
                        _buildSectionHeader("suggested", Icons.star_rounded),
                        LanguageSelectorWidget(
                          showSearch: false,
                          languages: LanguageConstants.nativeLanguages
                              .where((l) => ['en', 'es'].contains(l.code))
                              .toList(),
                          selectedLanguageCode: currentCode,
                          onSelected: (code) {
                            ref
                                .read(onboardingProvider.notifier)
                                .setNativeLanguage(code);
                          },
                        ),
                        const SizedBox(height: 24),
                        // All Languages
                        _buildSectionHeader(
                          "all Languages",
                          Icons.public_rounded,
                        ),
                        LanguageSelectorWidget(
                          showSearch: true,
                          languages: LanguageConstants.nativeLanguages
                              .where((l) => !['en', 'es'].contains(l.code))
                              .toList(),
                          selectedLanguageCode: currentCode,
                          onSelected: (code) {
                            ref
                                .read(onboardingProvider.notifier)
                                .setNativeLanguage(code);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Continue Button (Fixed)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bgLight.withOpacity(0.0),
                      bgLight.withOpacity(0.9),
                      bgLight,
                    ],
                    stops: const [0.0, 0.3, 0.6],
                  ),
                ),
                child: SafeArea(
                  child: PandaButton(
                    text: "continue",
                    onPressed: () => _onContinue(context, ref),
                    icon: Icons.arrow_forward_rounded,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareBtn(IconData icon) {
    return Container(
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
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textLight.withOpacity(0.8)),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textLight.withOpacity(0.8),
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
