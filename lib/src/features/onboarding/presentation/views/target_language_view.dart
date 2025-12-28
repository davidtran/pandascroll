import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/constants/language_constants.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/panda_button.dart';
import '../widgets/language_selector_widget.dart';
import 'language_level_view.dart';

class TargetLanguageView extends ConsumerStatefulWidget {
  const TargetLanguageView({super.key});

  @override
  ConsumerState<TargetLanguageView> createState() => _TargetLanguageViewState();
}

class _TargetLanguageViewState extends ConsumerState<TargetLanguageView> {
  String? _targetLangId;

  @override
  void initState() {
    super.initState();
    // Initialize with provider value or default to 'zh'
    _targetLangId = ref.read(onboardingProvider).targetLanguage ?? 'zh';
  }

  void _onStartAdventure() {
    if (_targetLangId != null) {
      ref.read(onboardingProvider.notifier).setTargetLanguage(_targetLangId!);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LanguageLevelView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color creamBg = Color(0xFFFEFDF5);
    const Color bgLight = Color(0xFFF0FDF4); // bg-background-light
    const Color primaryColor = AppColors.bambooGreen;
    const Color textMain = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: creamBg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Top Nav Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildSquareBtn(Icons.arrow_back),
                      Expanded(
                        child: Center(
                          child: Container(
                            height: 8,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50, // 50% progress
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildSquareBtn(Icons.settings),
                    ],
                  ),
                ),

                // Title Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    children: [
                      // Panda Icon is reused from asset
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Image.asset('assets/images/panda.png', height: 64),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "I want to learn...",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: textMain,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Choose the language you want to master.",
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: 'Nunito',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Language List
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    child: LanguageSelectorWidget(
                      languages: LanguageConstants.targetLanguages,
                      selectedLanguageCode: _targetLangId,
                      onSelected: (code) {
                        setState(() {
                          _targetLangId = code;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Bottom CTA
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
                    text: "Start Adventure",
                    onPressed: _onStartAdventure,
                    icon: Icons.rocket_launch_rounded,
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
