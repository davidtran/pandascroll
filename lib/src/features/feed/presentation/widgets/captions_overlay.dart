import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/video_model.dart';

class CaptionsOverlay extends StatefulWidget {
  final ValueNotifier<double> currentTimeNotifier;
  final List<Caption> captions;
  final List<String> translations;
  final Function(String, String) onWordTap;

  const CaptionsOverlay({
    super.key,
    required this.currentTimeNotifier,
    required this.captions,
    this.translations = const [],
    required this.onWordTap,
  });

  @override
  State<CaptionsOverlay> createState() => _CaptionsOverlayState();
}

class _CaptionsOverlayState extends State<CaptionsOverlay> {
  int? _activeIndex;

  @override
  void initState() {
    super.initState();
    widget.currentTimeNotifier.addListener(_onTimeChanged);
    // Initial check
    _onTimeChanged();
  }

  @override
  void dispose() {
    widget.currentTimeNotifier.removeListener(_onTimeChanged);
    super.dispose();
  }

  void _onTimeChanged() {
    if (!mounted) return;

    final currentTime = widget.currentTimeNotifier.value;
    final newIndex = _findActiveCaptionIndex(currentTime);

    if (newIndex != _activeIndex) {
      setState(() {
        _activeIndex = newIndex;
      });
    }
  }

  int? _findActiveCaptionIndex(double currentTime) {
    for (int i = 0; i < widget.captions.length; i++) {
      final caption = widget.captions[i];
      if (caption.words.isEmpty) continue;

      // Use the caption's full range
      if (currentTime >= caption.words.first.start &&
          currentTime <= caption.words.last.end) {
        return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_activeIndex == null) return const SizedBox.shrink();

    final activeIndex = _activeIndex!;
    final currentCaption = widget.captions[activeIndex];
    final currentTranslation = (activeIndex < widget.translations.length)
        ? widget.translations[activeIndex]
        : '';

    return _CaptionContainer(
      key: ValueKey(activeIndex), // Ensure state resets for new captions
      caption: currentCaption,
      translation: currentTranslation,
      currentTimeNotifier: widget.currentTimeNotifier,
      onWordTap: (word) => widget.onWordTap(word, currentCaption.text),
    );
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.pandaBlack, width: 3),
            boxShadow: const [
              BoxShadow(
                color: AppColors.pandaBlack,
                offset: Offset(4, 6),
                blurRadius: 0,
              ),
            ],
          ),
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
                    activeWordIndexNotifier: _activeWordIndexNotifier,
                    onTap: () => widget.onWordTap(entry.value.word),
                  );
                }).toList(),
              ),
              if (widget.translation.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.translation,
                  style:
                      const TextStyle(
                        color: AppColors
                            .textMain, // was bambooDark, now textMain or per design
                        fontFamily: 'Nunito', // Body font
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ).copyWith(
                        color: AppColors.bambooDark,
                      ), // Used bambooDark in HTML ref
                ),
              ],
            ],
          ),
        ),

        // Badge
        Positioned(
          top: -12,
          left: -8,
          child: Transform.rotate(
            angle: -0.1, // approx -6 degrees
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors
                    .bambooGreen, // Or accent orange from HTML example used orange, but let's stick to bamboo green or accent
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.pandaBlack, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.translate, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
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
      behavior: HitTestBehavior.opaque,
      child: ValueListenableBuilder<int>(
        valueListenable: activeWordIndexNotifier,
        builder: (context, activeIndex, _) {
          final isHighlighted = index == activeIndex;

          return Text(
            word.word,
            style: TextStyle(
              color: isHighlighted
                  ? AppColors.bambooDark
                  : AppColors.pandaBlack,
              fontFamily: 'Fredoka', // Display font
              fontSize: 16, // roughly text-lg/xl
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          );
        },
      ),
    );
  }
}
