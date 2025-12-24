import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/panda_button.dart';
import '../widgets/selectable_option_card.dart';
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

  // Updated to use URL images as per new design spec
  final List<Map<String, dynamic>> _targetLanguages = [
    {
      'name': 'Chinese',
      'hello': '你好',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBp76FMK1clf0RSjXXjSEP95JDYe7KyWPLzeHN8o9ki1b5iIhdWF_JV9SEvdQxnlKoq7Wg07mSuPWs8auuEdQih_4fvjALgMWGsUXRSQ6TzAm0nCZDwX54-VIh0-Hns4nlTcrihwbKo4jKQakgkY90miEKt6ATzZ4XjBrXhl2X8AVeYs7wUysqx7GyJo8EaRkbdrx3iuBhdAaidFySzkVdSeVZiFOx0CkmZycmVB5XNXkJQwq_7CVxTlVAji06wkLS4XFYZWTdlX9s',
      'id': 'zh',
      'available': true,
    },
    {
      'name': 'English',
      'hello': 'Hello',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB3o9h13vMUw0UlVF3KGfZ_GibGHgDzzI4cUYybLts9J2ZrM8v006e9A91nnplDP4TBmu3C3cqbGG_SVG9wtG1UOXqklHUUFdWGvvQ0dcqlXLHrdLIytG6I2HE4zRadCKpOYm_vnjXgc4DIa5eRfJvlC9HbTicodMY7fVXJ93LD2S2H-biRrfFoG5-Au1SxC-BoYcLpdhL81FI45PfguWBJA8onzM3ePPF-JKLk9BMiJuOzaOAdzZmf0sxNzHvyGJ3dQYggEf4GRpk',
      'id': 'en',
      'available': false,
    },
    {
      'name': 'Japanese',
      'hello': 'こんにちは',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBwYfUyX0byXwlYqptM4PnWwZdStwI4R-XylHm3-ogLozSEUXewMzi8jzp_welEzXElKWF3nln7-c8oNuzlrcPCEgCLRrbP2yOfeBaSJYC0XquGso6Tsl0WlKomBeHcVmWiPt900bSeDaJHlQGilRkjCq3m7z8Krf0onW_QmfRlY06_YOc2YjihXe2x9HifpQWvNrd89-wYg_sQuoR0jhlWhgbefOYhXRj6ISsRJeJLeZ5WuKgVEYDinM2T8YicGk2sGKjApwSIuxo',
      'id': 'ja',
      'available': false,
    },
    {
      'name': 'Korean',
      'hello': '안녕하세요',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA1PC1nsXp9OvwgQuD4vA_mq6-lFsgJ94vIh0H8gVf-Gd3fJZXabnGezXd4e25_leUzLFjvLF2L_7JyYPkSepdf8k0uRYvZ5aSJRJMvr8kPx9URogpxYreirui6KdwyjKubfjwUGEViLB2l87x5JTHe9eZEiSjjeDx1fHr4wIp0p1i-boGVYkmWUtaTlJAqZZBoCxBZ4MwsDA6JNPmACXzsMpucGXsFD5txq9TkpUgWBTp3yWNH3RrRZbUeWycbkLrJVDxTC7I0WBU',
      'id': 'ko',
      'available': false,
    },
    {
      'name': 'Spanish',
      'hello': 'Hola',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAECg0tPmVV8fo0cpg60DTlKjut-5A6zUT57ZcLUtLACWFnvv4-GmINVYnddPWgBu5rNd9s2reqd3GTB71TikA7HEZwap9QUUWphOG94qwPWCYMUwc1xAh-aAWiE4dd0mTd9JUmvgKtqzAVLVwL7ITVI6hHQMwTD6NLv-VFnCjpxDHvGDL99V4LyKWXzr343m52lWVJUgApMAqyCYFU6hwMUOsco1M5d6SvP_i21IGMJqjFLHh5YeDY8t5NL7P3WrkYgR5-nlpmKEw',
      'id': 'es',
      'available': false,
    },
  ];

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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    children: _targetLanguages.map((lang) {
                      final isAvailable = lang['available'] as bool;
                      final isSelected = _targetLangId == lang['id'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Opacity(
                              opacity: isAvailable ? 1.0 : 0.5,
                              child: SelectableOptionCard(
                                title: lang['name']!,
                                subtitle: lang['hello']!,
                                imageUrl: lang['flagUrl'],
                                isSelected: isSelected,
                                onTap: () {
                                  if (isAvailable) {
                                    setState(
                                      () =>
                                          _targetLangId = lang['id'] as String,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "${lang['name']} is coming soon!",
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            if (!isAvailable)
                              Positioned(
                                right: -8,
                                top: -8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(0, 2),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    "SOON",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
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
