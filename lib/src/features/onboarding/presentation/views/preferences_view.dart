import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/utils/navigation.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../feed/presentation/views/feed_view.dart';
import '../widgets/fun_button.dart';

class PreferencesView extends ConsumerStatefulWidget {
  const PreferencesView({super.key});

  @override
  ConsumerState<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends ConsumerState<PreferencesView> {
  // Level Selection
  bool _isHSK = false; // Toggle between CEFR and HSK
  String? _selectedLevel;

  final List<String> _cefrLevels = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6'];
  final List<String> _hskLevels = [
    'HSK1',
    'HSK2',
    'HSK3',
    'HSK4',
    'HSK5',
    'HSK6',
  ];

  // Category Selection
  final List<String> _categories = [
    'Comedy',
    'Gaming',
    'Music',
    'Lifestyle',
    'Movies',
    'Tech',
    'Travel',
    'Sports',
    'Facts',
  ];
  final Set<String> _selectedCategories = {};

  bool get _canContinue =>
      _selectedLevel != null && _selectedCategories.length == 3;

  Future<void> _onFinish() async {
    if (!_canContinue) return;

    try {
      await ref
          .read(authProvider.notifier)
          .updateUserProfile(
            level: _selectedLevel!,
            categories: _selectedCategories.toList(),
          );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const FeedView()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0FDF4),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildLevelSection(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildCategorySection(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Personalize It!",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Tell us what you know and what you love.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textLight,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelSection() {
    final levels = _isHSK ? _hskLevels : _cefrLevels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Your Level",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            // Toggle Switch
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildToggleOption("CEFR", !_isHSK),
                  _buildToggleOption("HSK", _isHSK),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: levels.map((level) {
            final isSelected = _selectedLevel == level;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLevel = level;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBrand : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBrand
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBrand.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMain,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToggleOption(String text, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isHSK = text == "HSK";
          _selectedLevel = null; // Reset selection on toggle
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Interests",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentFun.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${_selectedCategories.length}/3",
                style: const TextStyle(
                  color: AppColors.accentFun,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          "Pick exactly 3 topics to start.",
          style: TextStyle(color: AppColors.textLight),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _categories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCategories.remove(category);
                  } else {
                    if (_selectedCategories.length < 3) {
                      _selectedCategories.add(category);
                    } else {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("you can only choose 3!"),
                          duration: Duration(milliseconds: 1000),
                        ),
                      );
                    }
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentFun : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentFun
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accentFun.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textMain,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: FunButton(text: "Start Watching", onPressed: _onFinish),
        ),
      ),
    );
  }
}
