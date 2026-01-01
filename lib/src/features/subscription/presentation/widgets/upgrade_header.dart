import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/utils/language_utils.dart';
import 'package:pandascroll/src/features/profile/data/profile_repository.dart';
import 'package:pandascroll/src/features/profile/presentation/providers/profile_providers.dart';
import '../../../../core/theme/app_colors.dart';

class UpgradeHeader extends ConsumerWidget {
  const UpgradeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final targetLang = profile?['target_language'] as String?;
    final langName = LanguageUtils.getLanguageName(targetLang);
    return Column(
      children: [
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 40, // 4xl/5xl equivalent
              height: 1.1,
              fontFamily: 'Fredoka', // Display font
              fontWeight: FontWeight.w900,
              color: AppColors.pandaBlack,
            ),
            children: [
              TextSpan(text: "Invest in Your "),
              TextSpan(
                text: langName,
                style: TextStyle(color: AppColors.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Ready for more? Upgrade now to unlock all the features.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            color: AppColors.pandaBlack.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
