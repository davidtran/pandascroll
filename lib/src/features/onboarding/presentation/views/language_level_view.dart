import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/panda_button.dart';
import '../widgets/selectable_option_card.dart';
import 'interests_view.dart';

class LanguageLevelView extends ConsumerStatefulWidget {
  const LanguageLevelView({super.key});

  @override
  ConsumerState<LanguageLevelView> createState() => _LanguageLevelViewState();
}

class _LanguageLevelViewState extends ConsumerState<LanguageLevelView> {
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = ref.read(onboardingProvider).level;
  }

  final List<Map<String, String>> _levels = [
    {
      'id': 'beginner',
      'title': 'Beginner',
      'subtitle': "I'm starting from scratch",
      'icon': '🥚',
    },
    {
      'id': 'intermediate',
      'title': 'Intermediate',
      'subtitle': 'I can have simple chats',
      'icon': '🐣',
    },
    {
      'id': 'advanced',
      'title': 'Advanced',
      'subtitle': "I'm fluent or native",
      'icon': '🦅',
    },
  ];

  void _onContinue() {
    if (_selectedLevel != null) {
      ref.read(onboardingProvider.notifier).setLevel(_selectedLevel!);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InterestsView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgLight = Color(0xFFF0FDF4);
    const Color primaryColor = AppColors.bambooGreen;
    const Color textMain = AppColors.textMain;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Top Nav
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSquareBtn(Icons.arrow_back),
                      // Progress Bar 75%
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 75,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBrand,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    children: [
                      const SizedBox(height: 24),
                      // Title
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: textMain,
                            fontFamily: 'Fredoka',
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(text: "How's your "),
                            TextSpan(
                              text: "Chinese",
                              style: TextStyle(
                                color: AppColors.bambooDark,
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.wavy,
                                decorationColor: Color(0xFFFFD336),
                              ),
                            ),
                            TextSpan(text: "?"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Mascot Area (Changes based on selection)
                      _buildMascotState(),
                      const SizedBox(height: 32),

                      // Options
                      ..._levels.map((level) {
                        final isSelected = _selectedLevel == level['id'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SelectableOptionCard(
                            title: level['title']!,
                            subtitle: level['subtitle']!,
                            isSelected: isSelected,
                            onTap: () =>
                                setState(() => _selectedLevel = level['id']),
                          ),
                        );
                      }),

                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Quicksand',
                              ),
                              children: [
                                const TextSpan(text: "Not sure? "),
                                TextSpan(
                                  text: "Take a quick test",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      bgLight.withValues(alpha: 0.0),
                      bgLight.withValues(alpha: 0.9),
                      bgLight,
                    ],
                    stops: const [0.0, 0.3, 0.6],
                  ),
                ),
                child: SafeArea(
                  child: PandaButton(text: "CONTINUE", onPressed: _onContinue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotState() {
    final mascot = Image.asset('assets/images/panda.png', height: 64);

    // Beginner
    if (_selectedLevel == 'beginner' || _selectedLevel == null) {
      return Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              mascot,
              Positioned(top: 0, right: -10, child: _buildBadge("🌱")),
            ],
          ),
          const SizedBox(height: 16),
          _buildMessage("Just starting my journey!"),
        ],
      );
    }
    // Intermediate
    if (_selectedLevel == 'intermediate') {
      return Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              mascot,

              Positioned(top: 0, right: -10, child: _buildBadge("💬")),
            ],
          ),
          const SizedBox(height: 16),
          _buildMessage("Hungry for knowledge!", color: AppColors.bambooGreen),
        ],
      );
    }
    // Advanced
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            mascot,
            Positioned(
              top: 0,
              right: -10,
              child: Transform.rotate(angle: 0.2, child: _buildBadge("🎓")),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMessage("Dragon Warrior level!", color: Colors.orange),
      ],
    );
  }

  Widget _buildBadge(String emoji) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.grey[100]!, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _buildMessage(String text, {Color color = Colors.grey}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color == Colors.grey ? Colors.grey[500] : color,
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
              color: Colors.black.withValues(alpha: 0.1),
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
