import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../widgets/fun_button.dart';
import '../widgets/language_card.dart';
import '../../../feed/presentation/views/feed_view.dart';
import '../../../auth/presentation/views/login_view.dart';

class TargetLanguageView extends StatefulWidget {
  const TargetLanguageView({super.key});

  @override
  State<TargetLanguageView> createState() => _TargetLanguageViewState();
}

class _TargetLanguageViewState extends State<TargetLanguageView> {
  String? _targetLangId = 'zh'; // Auto-select Chinese

  final List<Map<String, dynamic>> _targetLanguages = [
    {'name': 'Chinese', 'hello': '你好', 'flag': '🇨🇳', 'id': 'zh', 'available': true},
    {'name': 'English', 'hello': 'Hello', 'flag': '🇺🇸', 'id': 'en', 'available': false},
    {'name': 'Japanese', 'hello': 'こんにちは', 'flag': '🇯🇵', 'id': 'ja', 'available': false},
    {'name': 'Korean', 'hello': '안녕하세요', 'flag': '🇰🇷', 'id': 'ko', 'available': false},
    {'name': 'Spanish', 'hello': 'Hola', 'flag': '🇪🇸', 'id': 'es', 'available': false},
  ];

  void _onStartAdventure() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
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
                    "I want to conquer...",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    "Choose your mission.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // List
                  ..._targetLanguages.map((lang) {
                    final isAvailable = lang['available'] as bool;
                    final isSelected = _targetLangId == lang['id'];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Opacity(
                        opacity: isAvailable ? 1.0 : 0.6,
                        child: LanguageCard(
                          language: lang['name'] as String,
                          nativeHello: lang['hello'] as String,
                          flagEmoji: lang['flag'] as String,
                          isSelected: isSelected,
                          isDisabled: !isAvailable,
                          onTap: () {
                            if (isAvailable) {
                              setState(() => _targetLangId = lang['id'] as String);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${lang['name']} is coming soon!")),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            // Bottom Button
            Container(
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
              child: SizedBox(
                width: double.infinity,
                child: FunButton(
                  text: "Start Adventure 🚀",
                  onPressed: _onStartAdventure,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
