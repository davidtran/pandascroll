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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Text(
              '${currentChunkIndex + 1}. $currentChunkTitle',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                height: 1.0,
                fontSize: 16,
                fontFamily: 'Fredoka',
              ),
            ),
          ),
          const SizedBox(height: 12),

          const SizedBox(height: 12),
        ],
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
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isPrimary
                ? AppColors.bambooGreen.withOpacity(0.8)
                : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.black, size: 16),
        ),
      ),
    );
  }
}
