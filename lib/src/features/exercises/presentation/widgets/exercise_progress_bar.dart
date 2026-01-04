import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';

class ExerciseProgressBar extends StatelessWidget {
  final int currentIndex;
  final int total;

  const ExerciseProgressBar({
    super.key,
    required this.currentIndex,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final bool isActive = index == currentIndex;
        final bool isPast = index < currentIndex;

        // Visual states:
        // Active: Wide, Green, Black Border
        // Past: Small, Green, Black Border (Completed)
        // Future: Small, Gray, Gray Border

        final double width = isActive ? 32 : 12;
        final Color bgColor = (isActive || isPast)
            ? AppColors.bambooGreen
            : Colors.grey[200]!;
        final Color borderColor = (isActive || isPast)
            ? AppColors.pandaBlack
            : Colors.grey[300]!;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: width,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.pandaBlack.withOpacity(0.1),
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
