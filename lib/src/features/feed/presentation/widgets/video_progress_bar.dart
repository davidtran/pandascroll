import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class VideoProgressBar extends StatelessWidget {
  final int totalChunks;
  final int currentChunkIndex;
  final ValueListenable<double>? currentTimeNotifier;
  final double chunkStartTime;
  final double chunkEndTime;

  const VideoProgressBar({
    super.key,
    this.totalChunks = 1,
    this.currentChunkIndex = 0,
    this.currentTimeNotifier,
    this.chunkStartTime = 0.0,
    this.chunkEndTime = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (totalChunks <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(totalChunks, (index) {
          final isActive = index == currentChunkIndex;
          final isPast = index < currentChunkIndex;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: isActive && currentTimeNotifier != null
                  ? ValueListenableBuilder<double>(
                      valueListenable: currentTimeNotifier!,
                      builder: (context, currentTime, child) {
                        double progress = 0.0;
                        if (chunkEndTime > chunkStartTime) {
                          progress =
                              (currentTime - chunkStartTime) /
                              (chunkEndTime - chunkStartTime);
                        }
                        progress = progress.clamp(0.0, 1.0);

                        return _buildBar(
                          context,
                          isActive: true,
                          isPast: false,
                          progress: progress,
                        );
                      },
                    )
                  : _buildBar(
                      context,
                      isActive: isActive,
                      isPast: isPast,
                      progress: isPast ? 1.0 : 0.0,
                    ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBar(
    BuildContext context, {
    required bool isActive,
    required bool isPast,
    required double progress,
  }) {
    // Styles
    final Color borderColor = (isActive || isPast)
        ? AppColors.pandaBlack
        : Colors.white.withOpacity(0.3);

    final List<BoxShadow> shadows = (isActive || isPast)
        ? [
            const BoxShadow(
              color: AppColors.pandaBlack,
              offset: Offset(1, 1),
              blurRadius: 0,
            ),
          ]
        : [];

    return Container(
      height: 4,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            heightFactor: 1.0,
            child: Container(color: AppColors.bambooGreen),
          ),
        ),
      ),
    );
  }
}
