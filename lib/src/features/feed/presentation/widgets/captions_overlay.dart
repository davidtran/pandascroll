import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/video_model.dart';

class CaptionsOverlay extends StatelessWidget {
  final ValueNotifier<double> currentTimeNotifier;
  final List<Caption> captions;
  final List<String> translations;
  final Function(String) onWordTap;

  const CaptionsOverlay({
    super.key,
    required this.currentTimeNotifier,
    required this.captions,
    this.translations = const [],
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: currentTimeNotifier,
      builder: (context, currentTime, child) {
        final activeIndex = _findActiveCaptionIndex(currentTime);

        if (activeIndex == null) {
          return const SizedBox.shrink();
        }

        final currentCaption = captions[activeIndex];
        final currentTranslation = (activeIndex < translations.length)
            ? translations[activeIndex]
            : '';

        print(currentTranslation);
        print(translations);

        final highlightedIndex = _findHighlightedWordIndex(
          currentCaption,
          currentTime,
        );

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
                children: currentCaption.words.asMap().entries.map((entry) {
                  final index = entry.key;
                  final word = entry.value;
                  final isHighlighted = index == highlightedIndex;

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

              if (currentTranslation.isNotEmpty) ...[
                const SizedBox(height: 4),
                // Translation
                Text(
                  currentTranslation,
                  textAlign: TextAlign.start,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  int? _findActiveCaptionIndex(double currentTime) {
    for (int i = 0; i < captions.length; i++) {
      final caption = captions[i];
      if (caption.words.isEmpty) continue;
      final start = caption.words.first.start;
      final end = caption.words.last.end;

      // Add a small buffer to end time to prevent flickering between captions
      if (currentTime >= start && currentTime < end) {
        return i;
      }
    }
    return null;
  }

  int? _findHighlightedWordIndex(Caption caption, double currentTime) {
    for (int i = 0; i < caption.words.length; i++) {
      final word = caption.words[i];
      if (currentTime >= word.start && currentTime <= word.end) {
        return i;
      }
    }
    return null;
  }
}
