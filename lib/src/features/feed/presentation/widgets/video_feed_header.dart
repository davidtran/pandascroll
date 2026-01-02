import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class VideoFeedHeader extends StatelessWidget {
  const VideoFeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Side: Level & Progress
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppColors.pandaBlack, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.pandaBlack,
                      offset: Offset(2, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Panda Icon
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColors.bambooGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.pandaBlack,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🐼', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    // Level Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LEVEL 1',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.pandaBlack,
                                      fontFamily:
                                          'Fredoka', // Or system default
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pandaBlack,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '51/200 XP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Progress Bar
                          Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: AppColors.pandaBlack,
                                width: 2,
                              ),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.25,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.levelBlue,
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(50),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Right Side: Streak
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.pandaBlack, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.pandaBlack,
                    offset: Offset(2, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '12',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.pandaBlack,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
