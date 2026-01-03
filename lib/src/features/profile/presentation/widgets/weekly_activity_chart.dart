import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/features/feed/presentation/providers/stats_provider.dart';
import '../../../../core/theme/app_colors.dart';

class WeeklyActivityChart extends ConsumerWidget {
  const WeeklyActivityChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const SizedBox(),
      data: (stats) {
        final weeklyActivity = List<double>.from(
          (stats['weekly_activity'] as List<dynamic>?)?.map(
                (e) => (e as num).toDouble(),
              ) ??
              [0, 0, 0, 0, 0, 0, 0],
        );

        final totalHours = weeklyActivity.reduce((a, b) => a + b);
        final maxHours = weeklyActivity.reduce((a, b) => a > b ? a : b);
        // Avoid division by zero
        final normalizeFactor = maxHours > 0 ? maxHours : 1.0;

        // Current Day (1=Mon, 7=Sun)
        final currentWeekday = DateTime.now().weekday;

        final days = ["m", "t", "w", "t", "f", "s", "s"];

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 0,
                offset: Offset(4, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "weekly activity",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.pandaBlack,
                      fontFamily: 'Fredoka',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrand.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "+${totalHours.toStringAsFixed(1)} hrs",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBrand,
                          ),
                        ),
                        const Icon(
                          Icons.trending_up,
                          size: 16,
                          color: AppColors.primaryBrand,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final value = weeklyActivity[index];
                    // Height factor (min 0.1 for visibility if 0?)
                    // Let's stick to strict proportion, maybe min height handled in bar
                    double heightFactor = value / normalizeFactor;
                    if (heightFactor == 0)
                      heightFactor = 0.05; // tiny bar for 0

                    return _buildBar(
                      days[index],
                      heightFactor,
                      isSelected: (index + 1) == currentWeekday,
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(String day, double heightFactor, {bool isSelected = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                heightFactor: heightFactor > 1.0 ? 1.0 : heightFactor,
                child: Container(
                  width: 12,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.bambooDark
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primaryBrand : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
