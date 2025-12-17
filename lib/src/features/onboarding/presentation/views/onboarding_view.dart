import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../widgets/fun_button.dart';
import '../widgets/onboarding_slide.dart';
import 'native_language_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      "icon": Icons.touch_app_rounded,
      "title": "Don't Just Watch. Do.",
      "body": "Learn real languages from real videos. Swipe up to learn, pause to play.",
      "color": AppColors.primaryBrand,
    },
    {
      "icon": Icons.quiz_rounded,
      "title": "Quizzes Inside the Action.",
      "body": "Tap the right answer while the video plays. Miss it? The video loops until you get it.",
      "color": AppColors.accentFun,
    },
    {
      "icon": Icons.sports_kabaddi_rounded, // Boss fight metaphor
      "title": "Defeat the Grammar Boss.",
      "body": "Prove your skills in epic boss battles. Earn XP, unlock loot, and master the language.",
      "color": AppColors.success,
    },
  ];

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to Language Selection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NativeLanguageView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                   // Skip logic
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Skipped Onboarding.")),
                  );
                },
                child: Text(
                  "Skip",
                  style: TextStyle(color: AppColors.textLight),
                ),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return OnboardingSlide(
                    icon: slide['icon'] as IconData,
                    title: slide['title'] as String,
                    body: slide['body'] as String,
                    iconColor: slide['color'] as Color,
                  );
                },
              ),
            ),
            
            // Indicators and Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primaryBrand
                              : AppColors.textLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Next/Finish Button
                  SizedBox(
                    width: double.infinity,
                    child: FunButton(
                      text: _currentPage == _slides.length - 1 ? "Let's Go!" : "Next",
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
