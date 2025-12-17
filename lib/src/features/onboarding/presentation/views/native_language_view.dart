import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../widgets/fun_button.dart';
import '../widgets/language_card.dart';
import 'target_language_view.dart';

class NativeLanguageView extends StatefulWidget {
  const NativeLanguageView({super.key});

  @override
  State<NativeLanguageView> createState() => _NativeLanguageViewState();
}

class _NativeLanguageViewState extends State<NativeLanguageView> {
  String? _selectedLangCode;

  final List<Map<String, String>> _nativeLanguages = [
    {'code': 'en', 'name': 'English', 'hello': 'Hello', 'flag': '🇺🇸'},
    {'code': 'vi', 'name': 'Vietnamese', 'hello': 'Xin chào', 'flag': '🇻🇳'},
    {'code': 'es', 'name': 'Spanish', 'hello': 'Hola', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'French', 'hello': 'Bonjour', 'flag': '🇫🇷'},
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Header
                  Text(
                    "I speak...",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "Select your native language.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // List
                  ..._nativeLanguages.map((lang) {
                    final isSelected = _selectedLangCode == lang['code'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: LanguageCard(
                        language: lang['name']!,
                        nativeHello: lang['hello']!,
                        flagEmoji: lang['flag']!,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedLangCode = lang['code']),
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            // Bottom Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _selectedLangCode != null ? 100 : 0,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: FunButton(
                    text: "Continue",
                    onPressed: _onContinue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
