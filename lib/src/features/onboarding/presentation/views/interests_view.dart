import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

import '../providers/onboarding_provider.dart';
import '../widgets/panda_button.dart';
import 'goal_view.dart';

class InterestsView extends ConsumerStatefulWidget {
  const InterestsView({super.key});

  @override
  ConsumerState<InterestsView> createState() => _InterestsViewState();
}

class _InterestsViewState extends ConsumerState<InterestsView> {
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(ref.read(onboardingProvider).categories);
  }

  // ... (Interest list remains the same, assuming it's static)
  final List<Map<String, dynamic>> _interests = [
    {
      'id': 'foodie',
      'label': 'Foodie',
      'emoji': '🥟',
      'color': Color(0xFFFFE066),
    },
    {
      'id': 'travel',
      'label': 'Travel',
      'emoji': '✈️',
      'color': Color(0xFFFFFFFF),
    },
    {'id': 'cpop', 'label': 'C-Pop', 'emoji': '🎵', 'color': Color(0xFFFFFFFF)},
    {
      'id': 'dramas',
      'label': 'Dramas',
      'emoji': '🎬',
      'color': Color(0xFFFF8FA3),
    },
    {
      'id': 'gaming',
      'label': 'Gaming',
      'emoji': '🎮',
      'color': Color(0xFFB580FF),
    },
    {'id': 'tech', 'label': 'Tech', 'emoji': '📱', 'color': Color(0xFFFFFFFF)},
    {
      'id': 'slang',
      'label': 'Slang',
      'emoji': '🤪',
      'color': Color(0xFF70C1FF),
    },
    {
      'id': 'culture',
      'label': 'Culture',
      'emoji': '🏮',
      'color': Color(0xFFFDBA74),
    },
    {
      'id': 'vlogs',
      'label': 'Vlogs',
      'emoji': '📹',
      'color': Color(0xFF5EEAD4),
    },
    {
      'id': 'career',
      'label': 'Career',
      'emoji': '💼',
      'color': Color(0xFFCBD5E1),
    },
  ];

  void _onStartLearning() {
    // Sync state to provider manually if needed, or rely on toggle.
    // Since we handle toggles individually, we are good.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoalView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colors from HTML/Config
    const Color bgLight = Color(0xFFF0FDF4);
    const Color primary = AppColors.bambooGreen;
    final bool canContinue = _selectedIds.length >= 3;

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_buildSquareBtn(Icons.arrow_back)],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    children: [
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMain,
                            fontFamily: 'Fredoka',
                            height: 1.1,
                          ),
                          children: [
                            TextSpan(text: "what are you into? "),
                            TextSpan(text: "🐼"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "pick at least 3 topics to build your custom feed.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMain.withOpacity(0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1,
                            ),
                        itemCount: _interests.length,
                        itemBuilder: (context, index) {
                          final item = _interests[index];
                          final isSelected = _selectedIds.contains(item['id']);

                          return _buildInterestCard(item, isSelected, primary);
                        },
                      ),

                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          "Don't worry, you can change these later!",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Bottom CTA (Slide Up)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              bottom: canContinue ? 0 : -220, // Hide below screen
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      bgLight.withOpacity(0.0),
                      bgLight.withOpacity(0.95),
                      bgLight,
                    ],
                    stops: const [0.0, 0.4, 0.7],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: PandaButton(
                    text: "start learning",
                    onPressed: _onStartLearning,
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

  Widget _buildInterestCard(
    Map<String, dynamic> item,
    bool isSelected,
    Color primary,
  ) {
    final Color itemColor = item['color'];

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedIds.remove(item['id']);
          } else {
            _selectedIds.add(item['id']);
          }
        });
        ref.read(onboardingProvider.notifier).toggleCategory(item['id']);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(
                  color: AppColors.bambooDark,
                  width: 2,
                ) // Simplified border for brevity
              : Border.all(color: const Color(0xFFDFDFDF), width: 2),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item['emoji'], style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 12),
                  Text(
                    item['label'].toLowerCase(),
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),

            // Checkmark (Animated scale)
            Positioned(
              top: 12,
              right: 12,
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.elasticOut,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
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
