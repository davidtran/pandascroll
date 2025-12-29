import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/daily_goal/count_down_text.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../profile/presentation/providers/profile_providers.dart';
import 'stripe_progress_bar.dart';
import '../../providers/paw_provider.dart';

class LanguageLevelWidget extends ConsumerWidget {
  const LanguageLevelWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userLanguageProfileProvider).value;
    print(profile);
    if (profile == null) return const SizedBox.shrink();
    final pawAsync = ref.watch(pawProvider);
    final pawState = pawAsync.value;
    final totalXpForLevel = profile.xp + profile.remainXp;
    final progress = totalXpForLevel > 0
        ? (profile.xp / totalXpForLevel).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.white, blurRadius: 0, offset: Offset(1, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left: Panda Icon
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBrand,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Image.asset(
              'assets/images/panda.png',
              width: 20,
              height: 20,
              key: ref.watch(pandaIconKeyProvider),
            ),
          ),
          const SizedBox(width: 8),

          // Center: Level & XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "LEVEL ${profile.level}",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Fredoka',
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  SizedBox(
                    width: 80, // Slightly reduced width to fit paw
                    child: StripeProgressBar(progress: progress),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black,
                    ),
                    child: Text(
                      "${profile.xp.toInt()}/${totalXpForLevel.toInt()} XP",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Divider
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 8),

          // Right: Paw Count
          if (pawState != null)
            Row(
              children: [
                Image.asset(
                  'assets/images/paw.png',
                  width: 16,
                  height: 16,
                  key: ref.watch(pawIconKeyProvider),
                  color: pawState.count == 0
                      ? Colors.grey
                      : null, // Grey out if 0
                ),
                const SizedBox(width: 4),
                Text(
                  "x${pawState.count}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // Adjusted font size
                    color: AppColors.pandaBlack,
                    fontFamily: 'Fredoka',
                  ),
                ),
                if (pawState.count < 5)
                  CountdownText(minutes: pawState.regenMinutes),
              ],
            ),
        ],
      ),
    );
  }
}
