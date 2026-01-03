import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/features/feed/presentation/providers/stats_provider.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileStats extends ConsumerWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return statsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBrand),
      ),
      error: (err, stack) => Text('Error: $err'),
      data: (stats) {
        final streak = stats['streak_count'] ?? 0;
        final score = (stats['answer_count'] ?? 0).toInt();
        final durationSeconds = (stats['duration_seconds'] ?? 0).toDouble();
        final accuracy = stats['accuracy'] ?? 0;

        // Format Duration
        String timeString;
        if (durationSeconds < 60) {
          timeString = "${durationSeconds.toInt()}s";
        } else if (durationSeconds < 3600) {
          timeString = "${(durationSeconds / 60).toStringAsFixed(1)}m";
        } else {
          timeString = "${(durationSeconds / 3600).toStringAsFixed(1)}h";
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: AppColors.primaryBrand),
                  SizedBox(width: 8),
                  Text(
                    "my progress",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.pandaBlack,
                      fontFamily: 'Fredoka',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard(
                  icon: Icons.local_fire_department,
                  value: "$streak Days",
                  label: "streak",
                  color: Colors.orange,
                  bgColor: Colors.white,
                ),
                _buildStatCard(
                  icon: Icons.forest,
                  value: "$score",
                  label: "total Score",
                  color: AppColors.primaryBrand,
                  bgColor: Colors.white,
                ),
                _buildStatCard(
                  icon: Icons.schedule,
                  value: timeString,
                  label: "time",
                  color: Colors.purple,
                  bgColor: Colors.white,
                ),
                _buildStatCard(
                  icon: Icons.stars,
                  value: "$accuracy%",
                  label: "accuracy",
                  color: Colors.blue,
                  bgColor: Colors.white,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 0, offset: Offset(4, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
