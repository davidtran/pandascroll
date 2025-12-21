import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import 'target_language_view.dart';
import '../widgets/panda_button.dart';
import '../widgets/selectable_option_card.dart';

class NativeLanguageView extends StatefulWidget {
  const NativeLanguageView({super.key});

  @override
  State<NativeLanguageView> createState() => _NativeLanguageViewState();
}

class _NativeLanguageViewState extends State<NativeLanguageView> {
  String? _selectedLangCode;

  // Mock data as per design
  final List<Map<String, String>> _suggestedLanguages = [
    {
      'code': 'en',
      'name': 'English',
      'native': 'English',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB3o9h13vMUw0UlVF3KGfZ_GibGHgDzzI4cUYybLts9J2ZrM8v006e9A91nnplDP4TBmu3C3cqbGG_SVG9wtG1UOXqklHUUFdWGvvQ0dcqlXLHrdLIytG6I2HE4zRadCKpOYm_vnjXgc4DIa5eRfJvlC9HbTicodMY7fVXJ93LD2S2H-biRrfFoG5-Au1SxC-BoYcLpdhL81FI45PfguWBJA8onzM3ePPF-JKLk9BMiJuOzaOAdzZmf0sxNzHvyGJ3dQYggEf4GRpk',
    },
    {
      'code': 'es',
      'name': 'Spanish',
      'native': 'Español',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAECg0tPmVV8fo0cpg60DTlKjut-5A6zUT57ZcLUtLACWFnvv4-GmINVYnddPWgBu5rNd9s2reqd3GTB71TikA7HEZwap9QUUWphOG94qwPWCYMUwc1xAh-aAWiE4dd0mTd9JUmvgKtqzAVLVwL7ITVI6hHQMwTD6NLv-VFnCjpxDHvGDL99V4LyKWXzr343m52lWVJUgApMAqyCYFU6hwMUOsco1M5d6SvP_i21IGMJqjFLHh5YeDY8t5NL7P3WrkYgR5-nlpmKEw',
    },
  ];

  final List<Map<String, String>> _allLanguages = [
    {
      'code': 'fr',
      'name': 'French',
      'native': 'Français',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDwOm5KmmFIac7iciPwsWWR4e__D4dPGDx83ROBvFEF8W5Z2r5c6tnbaC2pPSJrcvR0V6yQGEIUN0EEXi6Ct4esoEoxFhCAUj6zhS7kY8dmGBzcd3G4s0HXwdchth1hqSRqMFhnxKherszvl-D5gqBwVfFRPXolakN3LDtN7GcYGRlumy7jSPYwTwYwsQ9bW50rNQ7WiS1RascDQtWToTrqTDD4ahTuUnyvGxKUgX0L12d1MDiSszEjon02ZdBF2usbFqcJlllTjEE',
    },
    {
      'code': 'de',
      'name': 'German',
      'native': 'Deutsch',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBHmhqJoZsTIjCSZMQp28s8jBVIZgQ7RxXIK7o3nZUHm7Cgx9Bj85fd-JVnzzKQBbOtQWwp_E5NZ30BJX7II3yp-sR0Kw7tvVjk_bUv06ZOaiD7S6FUOvVwn8sGehuxQwBGHn_3Gf7PYw7WqqFWKNRdng89OOEDvDT8gHEiIGd4o3rIxG7EuIIgh4CIdI_UXu2WsLmWPebnWiYuAf_ZCoVeopRmWIR8bViUx8riI3s45in5s_VA6ZBJxmnYzjLBrrbKuO3vBc2i8Rs',
    },
    {
      'code': 'jp',
      'name': 'Japanese',
      'native': '日本語',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBwYfUyX0byXwlYqptM4PnWwZdStwI4R-XylHm3-ogLozSEUXewMzi8jzp_welEzXElKWF3nln7-c8oNuzlrcPCEgCLRrbP2yOfeBaSJYC0XquGso6Tsl0WlKomBeHcVmWiPt900bSeDaJHlQGilRkjCq3m7z8Krf0onW_QmfRlY06_YOc2YjihXe2x9HifpQWvNrd89-wYg_sQuoR0jhlWhgbefOYhXRj6ISsRJeJLeZ5WuKgVEYDinM2T8YicGk2sGKjApwSIuxo',
    },
    {
      'code': 'cn',
      'name': 'Chinese',
      'native': '中文',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBp76FMK1clf0RSjXXjSEP95JDYe7KyWPLzeHN8o9ki1b5iIhdWF_JV9SEvdQxnlKoq7Wg07mSuPWs8auuEdQih_4fvjALgMWGsUXRSQ6TzAm0nCZDwX54-VIh0-Hns4nlTcrihwbKo4jKQakgkY90miEKt6ATzZ4XjBrXhl2X8AVeYs7wUysqx7GyJo8EaRkbdrx3iuBhdAaidFySzkVdSeVZiFOx0CkmZycmVB5XNXkJQwq_7CVxTlVAji06wkLS4XFYZWTdlX9s',
    },
    {
      'code': 'kr',
      'name': 'Korean',
      'native': '한국어',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA1PC1nsXp9OvwgQuD4vA_mq6-lFsgJ94vIh0H8gVf-Gd3fJZXabnGezXd4e25_leUzLFjvLF2L_7JyYPkSepdf8k0uRYvZ5aSJRJMvr8kPx9URogpxYreirui6KdwyjKubfjwUGEViLB2l87x5JTHe9eZEiSjjeDx1fHr4wIp0p1i-boGVYkmWUtaTlJAqZZBoCxBZ4MwsDA6JNPmACXzsMpucGXsFD5txq9TkpUgWBTp3yWNH3RrRZbUeWycbkLrJVDxTC7I0WBU',
    },
    {
      'code': 'pt',
      'name': 'Portuguese',
      'native': 'Português',
      'flagUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD3S9zIxo4YYVcX4a1fQOdFliN5UYl_zqk6Bgm2-nzBZVqCr7J78SPJnvBPS5XunRN60_SiHhRgvq787vw1RJmmAugtyI2-jZSyP0YK3QAoAYG-kqs5aBcWmUmPkv_qT3WqE7I2PGH8vKujDE9PshVXVBmL6fpwrPgwLwNqTOa8Q4qa1WIHOTVn-XCLy8YySG1sn9IJsEGW3hDo0ClHkq7Giu-si8ALHZbdddOdNInStiOLmZ4YE6LnvGyfX0ol0xco3Ua9fHqJxt8',
    },
  ];

  void _onContinue() {
    if (_selectedLangCode != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TargetLanguageView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgLight = Color(0xFFF0FDF4); // bg-background-light
    const Color primaryColor = AppColors.bambooGreen; // 0xFF4ADE80
    const Color textMain = Color(0xFF1E293B); // text-main

    return Scaffold(
      backgroundColor: bgLight,
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
                        "Which language?",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: textMain,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Select your native language so Panpan can help you!",
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

                // Search Bar
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 24),
                //   child: Container(
                //     height: 56,
                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(28),
                //       border: Border.all(color: Colors.grey[200]!, width: 2),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withOpacity(0.05),
                //           offset: const Offset(0, 2),
                //           blurRadius: 2,
                //         ),
                //       ],
                //     ),

                //     child: const Row(
                //       children: [
                //         Icon(Icons.search, color: Colors.grey),
                //         SizedBox(width: 12),
                //         Text(
                //           "Search languages...",
                //           style: TextStyle(
                //             color: Colors.grey,
                //             fontSize: 18,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 24),

                // Language List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    children: [
                      // Suggested
                      _buildSectionHeader("Suggested", Icons.star_rounded),
                      ..._suggestedLanguages.map((l) => _buildLanguageTile(l)),
                      const SizedBox(height: 24),
                      // All Languages
                      _buildSectionHeader(
                        "All Languages",
                        Icons.public_rounded,
                      ),
                      ..._allLanguages.map((l) => _buildLanguageTile(l)),
                    ],
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
                    text: "Continue",
                    onPressed: _onContinue,
                    icon: Icons.arrow_forward_rounded,
                    backgroundColor: primaryColor,
                    textColor: Colors.white,
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

  Widget _buildLanguageTile(Map<String, String> lang) {
    final bool isSelected = _selectedLangCode == lang['code'];
    final Color primary = AppColors.bambooGreen;

    return SelectableOptionCard(
      title: lang['name']!,
      subtitle: lang['native']!,

      isSelected: isSelected,
      onTap: () {
        setState(() {
          _selectedLangCode = lang['code'];
        });
      },
    );
  }
}
