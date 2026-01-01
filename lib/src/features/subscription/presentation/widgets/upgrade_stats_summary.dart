import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/feed/presentation/providers/stats_provider.dart';
import 'package:pandascroll/src/features/profile/presentation/providers/profile_providers.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/daily_goal/stripe_progress_bar.dart';

class UpgradeStatsSummary extends ConsumerWidget {
  const UpgradeStatsSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Level / XP
    final profile = ref.watch(userLanguageProfileProvider).value;

    // 2. Flashcards / Stats
    final statsAsync = ref.watch(userStatsProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.pandaBlack, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardSecondaryShadow,
            blurRadius: 0, // Hard shadow
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Level (Full Width or Prominent)
          if (profile != null)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "CURRENT LEVEL",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.pandaBlack.withOpacity(0.8),
                              fontFamily: 'Nunito',
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Level ${profile.level}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.pandaBlack,
                          fontFamily: 'Fredoka',
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.pandaBlack,
                                width: 2,
                              ),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: (profile.xp + profile.remainXp) > 0
                                ? (profile.xp / (profile.xp + profile.remainXp))
                                      .clamp(0.0, 1.0)
                                : 0,
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBrand,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.pandaBlack,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${profile.xp.toInt()} / ${(profile.xp + profile.remainXp).toInt()} XP to next level",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pandaBlack,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Row 2: Stats Grid
          statsAsync.when(
            loading: () => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.pandaBlack,
                ),
              ),
            ),
            error: (_, __) => const SizedBox(),
            data: (stats) {
              final score = (stats['answer_count'] ?? 0).toInt();
              final streak = stats['streak_count'] ?? 0;
              final videoCount = (stats['video_count'] ?? 0).toInt();
              final durationSeconds = (stats['duration_seconds'] ?? 0)
                  .toDouble();

              // Format Duration
              String timeString;
              if (durationSeconds < 60) {
                timeString = "${durationSeconds.toInt()}s";
              } else if (durationSeconds < 3600) {
                timeString = "${(durationSeconds / 60).toStringAsFixed(1)}m";
              } else {
                timeString = "${(durationSeconds / 3600).toStringAsFixed(1)}h";
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 16) / 2; // 2 cols
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _StatItem(
                        width: itemWidth,
                        icon: Icons.style,
                        value: "$score",
                        label: "Cards",
                        color: const Color(0xFFA5F3FC), // Cyan-200
                        iconColor: const Color(0xFF0891B2),
                      ),
                      _StatItem(
                        width: itemWidth,
                        icon: Icons.play_circle_fill,
                        value: "$videoCount",
                        label: "Videos",
                        color: const Color(0xFFE9D5FF), // Purple-200
                        iconColor: const Color(0xFF9333EA),
                      ),
                      _StatItem(
                        width: itemWidth,
                        icon: Icons.schedule,
                        value: timeString,
                        label: "Time",
                        color: const Color(0xFFFECACA), // Red-200
                        iconColor: const Color(0xFFDC2626),
                      ),
                      _StatItem(
                        width: itemWidth,
                        icon: Icons.local_fire_department,
                        value: "$streak",
                        label: "Streak",
                        color: const Color(0xFFFED7AA), // Orange-200
                        iconColor: const Color(0xFFEA580C),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final double width;
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color iconColor;

  const _StatItem({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pandaBlack, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardSecondaryShadow,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.pandaBlack, width: 1.5),
            ),
            child: Icon(icon, color: AppColors.pandaBlack, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.pandaBlack,
                    fontFamily: 'Fredoka',
                  ),
                ),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pandaBlack.withOpacity(0.6),
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
