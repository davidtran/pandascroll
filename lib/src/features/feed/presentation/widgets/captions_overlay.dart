import 'package:flutter/material.dart';
import '../../domain/models/video_model.dart';
import '../../../../core/theme/app_colors.dart';

class CaptionsOverlay extends StatelessWidget {
  final VideoModel video;
  final double currentTime;

  final Function(String) onWordTap;

  const CaptionsOverlay({
    super.key,
    required this.video,
    required this.currentTime,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    // Local timer is used now, so we use currentTime directly
    final adjustedTime = currentTime;

    // Find the current or most recent caption
    Caption? currentCaption;
    int currentIndex = -1;

    for (int i = 0; i < video.captions.length; i++) {
      final caption = video.captions[i];
      if (caption.words.isEmpty) continue;

      final start = caption.words.first.start;

      // If the caption has started, it's a candidate.
      // Since we iterate in order, the last one we find that satisfies this
      // will be the most recent one.
      if (adjustedTime >= start) {
        currentCaption = caption;
        currentIndex = i;
      } else {
        // Assuming captions are sorted by time, we can stop once we hit a future caption
        break;
      }
    }

    if (currentCaption == null) {
      return const SizedBox.shrink();
    }

    final translation =
        (currentIndex >= 0 && currentIndex < video.translations.length)
        ? video.translations[currentIndex]
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original Text with Highlighting
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 2,

            children: currentCaption.words.map((word) {
              final isHighlighted =
                  adjustedTime >= word.start && adjustedTime <= word.end;
              return GestureDetector(
                onTap: () => onWordTap(word.word),
                child: Text(
                  word.word,
                  style: TextStyle(
                    color: isHighlighted
                        ? AppColors.primaryBrand
                        : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          if (translation.isNotEmpty) ...[
            const SizedBox(height: 4),
            // Translation
            Text(
              translation,
              textAlign: TextAlign.start,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
