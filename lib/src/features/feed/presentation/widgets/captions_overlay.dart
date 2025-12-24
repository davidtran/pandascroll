import 'package:flutter/material.dart';
import 'dart:ui';
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
    // We only want to rebuild the main container when the CAPTION index changes,
    // not every time the time updates.
    return ValueListenableBuilder<double>(
      valueListenable: currentTimeNotifier,
      builder: (context, currentTime, child) {
        final activeIndex = _findActiveCaptionIndex(currentTime);
        if (activeIndex == null) return const SizedBox.shrink();

        final currentCaption = captions[activeIndex];
        final currentTranslation = (activeIndex < translations.length)
            ? translations[activeIndex]
            : '';

        return _CaptionContainer(
          key: ValueKey(activeIndex), // Ensure state resets for new captions
          caption: currentCaption,
          translation: currentTranslation,
          currentTimeNotifier: currentTimeNotifier,
          onWordTap: onWordTap,
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
}

class _CaptionContainer extends StatelessWidget {
  final Caption caption;
  final String translation;
  final ValueNotifier<double> currentTimeNotifier;
  final Function(String) onWordTap;

  const _CaptionContainer({
    super.key,
    required this.caption,
    required this.translation,
    required this.currentTimeNotifier,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(32),
    );

    return ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: ShapeDecoration(color: Colors.black54, shape: shape),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.start,
                spacing: 4,
                children: caption.words.map((word) {
                  return _HighlightableWord(
                    word: word,
                    currentTimeNotifier: currentTimeNotifier,
                    onTap: () => onWordTap(word.word),
                  );
                }).toList(),
              ),
              if (translation.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    translation,
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightableWord extends StatelessWidget {
  final Word word;
  final ValueNotifier<double> currentTimeNotifier;
  final VoidCallback onTap;

  const _HighlightableWord({
    required this.word,
    required this.currentTimeNotifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ValueListenableBuilder<double>(
        valueListenable: currentTimeNotifier,
        builder: (context, time, _) {
          final isHighlighted = time >= word.start && time <= word.end;

          return Text(
            word.word,
            style: TextStyle(
              color: isHighlighted ? AppColors.bambooDark : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }
}
