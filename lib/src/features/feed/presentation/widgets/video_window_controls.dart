import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/with_interceptor.dart';
import '../../../../core/theme/app_colors.dart';

class VideoWindowControls extends StatelessWidget {
  final String videoTitle;
  final String currentChunkTitle;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool hasPrev;
  final bool hasNext;
  final int totalChunks;
  final int currentChunkIndex;

  // Animation/Progress fields
  final ValueListenable<double>? currentTimeNotifier;
  final double chunkStartTime;
  final double chunkEndTime;

  const VideoWindowControls({
    super.key,
    required this.videoTitle,
    required this.currentChunkTitle,
    this.onPrev,
    this.onNext,
    this.hasPrev = false,
    this.hasNext = false,
    this.totalChunks = 1,
    this.currentChunkIndex = 0,
    this.currentTimeNotifier,
    this.chunkStartTime = 0.0,
    this.chunkEndTime = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return withInterceptor(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              videoTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.0,
                fontSize: 21,
                shadows: [
                  const Shadow(
                    color: AppColors.pandaBlack,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Progress Bars
          if (totalChunks > 0)
            Padding(
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
            ),

          const SizedBox(height: 12),

          // Navigation Arrows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: hasPrev ? onPrev : null,
                ),
                _NavButton(
                  icon: Icons.arrow_forward_rounded,
                  onTap: hasNext ? onNext : null,
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
    BuildContext context, {
    required bool isActive,
    required bool isPast,
    required double progress,
  }) {
    print('$isActive $progress');
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
      height: 8,
      padding: const EdgeInsets.all(0), // Inset for border
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4), // Base background
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Align(
          alignment: Alignment.centerLeft,
          // CHANGED: Removed TweenAnimationBuilder
          // Use FractionallySizedBox for instant, direct control via progress
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  const _NavButton({required this.icon, this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return Opacity(
        opacity: 0.5,
        child: Container(
          width: 24, // Slightly smaller than pure huge buttons
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppColors.bambooGreen.withOpacity(0.8)
                  : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: isPrimary
                    ? AppColors.bambooLight.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}
