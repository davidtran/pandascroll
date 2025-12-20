import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../domain/models/exercise_model.dart';

import 'package:just_audio/just_audio.dart';

class ClozeWidget extends StatefulWidget {
  final ClozeData data;
  final VoidCallback onCorrect;
  final String audioUrl;

  const ClozeWidget({
    super.key,
    required this.data,
    required this.onCorrect,
    required this.audioUrl,
  });

  @override
  State<ClozeWidget> createState() => _ClozeWidgetState();
}

class _ClozeWidgetState extends State<ClozeWidget> {
  String? _selectedOption;
  bool _isAnswered = false;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();

    // Listen to player state to update UI
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying =
              state.playing &&
              state.processingState != ProcessingState.completed &&
              state.processingState != ProcessingState.idle;
        });
      }
    });
  }

  @override
  void didUpdateWidget(ClozeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _resetState();
      _initAudio();
    }
  }

  void _resetState() {
    setState(() {
      _selectedOption = null;
      _isAnswered = false;
      _isPlaying = false;
    });
    _audioPlayer.stop();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
      await _audioPlayer.setClip(
        start: Duration(milliseconds: (widget.data.audioStart * 1000).toInt()),
        end: Duration(milliseconds: (widget.data.audioEnd * 1000).toInt()),
      );
    } catch (e) {
      debugPrint("Error initializing audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      // Seek to start of clip (0 relative to clip) or just play if clip is set
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    }
  }

  void _handleOptionTap(String option) {
    if (_isAnswered) return;

    setState(() {
      _selectedOption = option;
      _isAnswered = true;
    });

    if (option == widget.data.correctAnswer) {
      Future.delayed(const Duration(milliseconds: 1000), widget.onCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Split sentence by '___' to insert the blank
    final parts = widget.data.sentenceDisplay.split('___');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Audio Button
        GestureDetector(
          onTap: _playAudio,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBrand.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
              color: AppColors.primaryBrand,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textMain,
                height: 1.5,
              ),
              children: [
                if (parts.isNotEmpty) TextSpan(text: parts[0]),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _isAnswered
                              ? (_selectedOption == widget.data.correctAnswer
                                    ? Colors.green
                                    : Colors.red)
                              : Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _selectedOption ?? "   ",
                      style: TextStyle(
                        color: _isAnswered
                            ? (_selectedOption == widget.data.correctAnswer
                                  ? Colors.green
                                  : Colors.red)
                            : Colors.transparent,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                if (parts.length > 1) TextSpan(text: parts[1]),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Options Grid (Column of Rows)
        ...List.generate((widget.data.options.length / 2).ceil(), (rowIndex) {
          final startIndex = rowIndex * 2;
          final endIndex = startIndex + 2;
          final rowOptions = widget.data.options.sublist(
            startIndex,
            endIndex > widget.data.options.length
                ? widget.data.options.length
                : endIndex,
          );

          final rowWidgets = rowOptions.map((option) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: AspectRatio(
                  aspectRatio: 2.0,
                  child: _buildOption(option),
                ),
              ),
            );
          }).toList();

          // If row has only 1 item, add an empty Expanded to keep grid alignment
          if (rowWidgets.length < 2) {
            rowWidgets.add(const Expanded(child: SizedBox()));
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(children: rowWidgets),
          );
        }),
      ],
    );
  }

  Widget _buildOption(String option) {
    final isSelected = _selectedOption == option;
    final isCorrect = option == widget.data.correctAnswer;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade200;
    Color textColor = AppColors.textMain;

    if (_isAnswered) {
      if (isSelected) {
        if (isCorrect) {
          backgroundColor = Colors.green.shade100;
          borderColor = Colors.green;
          textColor = Colors.green.shade900;
        } else {
          backgroundColor = Colors.red.shade100;
          borderColor = Colors.red;
          textColor = Colors.red.shade900;
        }
      } else if (isCorrect) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
      }
    }

    return GestureDetector(
      onTap: () => _handleOptionTap(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Text(
          option,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
