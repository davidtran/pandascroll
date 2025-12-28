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

      // Use the caption's full range
      if (currentTime >= caption.words.first.start &&
          currentTime <= caption.words.last.end) {
        return i;
      }
    }
    return null;
  }
}

class _CaptionContainer extends StatefulWidget {
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
  State<_CaptionContainer> createState() => _CaptionContainerState();
}

class _CaptionContainerState extends State<_CaptionContainer> {
  // This notifier only fires when the active word INDEX changes (e.g., 2 times/sec),
  // not when the time changes (60 times/sec).
  late final ValueNotifier<int> _activeWordIndexNotifier;

  @override
  void initState() {
    super.initState();
    _activeWordIndexNotifier = ValueNotifier<int>(-1);

    // Listen to the high-frequency timer manually
    widget.currentTimeNotifier.addListener(_onTimeChanged);
  }

  @override
  void dispose() {
    widget.currentTimeNotifier.removeListener(_onTimeChanged);
    _activeWordIndexNotifier.dispose();
    super.dispose();
  }

  void _onTimeChanged() {
    final time = widget.currentTimeNotifier.value;
    int newIndex = -1;

    // Find which word is currently active
    // This loop is purely logic (very fast), no UI rebuilding happens here.
    for (int i = 0; i < widget.caption.words.length; i++) {
      final w = widget.caption.words[i];
      if (time >= w.start && time <= w.end) {
        newIndex = i;
        break;
      }
    }

    // ONLY notify listeners if the word index effectively changed
    if (newIndex != _activeWordIndexNotifier.value) {
      _activeWordIndexNotifier.value = newIndex;
    }
  }

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
                children: widget.caption.words.asMap().entries.map((entry) {
                  return _HighlightableWord(
                    word: entry.value,
                    index: entry.key,
                    // Pass the low-frequency notifier
                    activeWordIndexNotifier: _activeWordIndexNotifier,
                    onTap: () => widget.onWordTap(entry.value.word),
                  );
                }).toList(),
              ),
              if (widget.translation.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.translation,
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
  final int index;
  final ValueNotifier<int> activeWordIndexNotifier;
  final VoidCallback onTap;

  const _HighlightableWord({
    required this.word,
    required this.index,
    required this.activeWordIndexNotifier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ValueListenableBuilder<int>(
        valueListenable: activeWordIndexNotifier,
        builder: (context, activeIndex, _) {
          // This builder now only runs ~2 times per second
          // (only when the active word actually flips).
          final isHighlighted = index == activeIndex;

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
