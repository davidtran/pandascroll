import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../domain/models/exercise_model.dart';
import 'package:just_audio/just_audio.dart';

class ClozeWidget extends StatefulWidget {
  final ClozeData data;
  final VoidCallback onCorrect;
  final VoidCallback? onWrong;
  final String audioUrl;
  final Future<void> Function({required double start, required double end})
  onPlayAudio;
  final Future<void> Function() onPauseAudio;
  final Stream<PlayerState> audioStateStream;

  const ClozeWidget({
    super.key,
    required this.data,
    required this.onCorrect,
    this.onWrong,
    required this.audioUrl,
    required this.onPlayAudio,
    required this.onPauseAudio,
    required this.audioStateStream,
  });

  @override
  State<ClozeWidget> createState() => _ClozeWidgetState();
}

class _ClozeWidgetState extends State<ClozeWidget> {
  String? _selectedOption;
  bool _isAnswered = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Listen to player state to update UI
    widget.audioStateStream.listen((state) {
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
    if (widget.key != oldWidget.key) {
      _resetState();
      // _initAudio(); // Removed
    }
  }

  void _resetState() {
    setState(() {
      _selectedOption = null;
      _isAnswered = false;
      _isPlaying = false;
    });
    // _audioPlayer.stop(); // Removed
  }

  // Future<void> _initAudio() async { ... } // Removed

  @override
  void dispose() {
    // _audioPlayer.dispose(); // Removed
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (_isPlaying) {
      await widget.onPauseAudio();
    } else {
      await widget.onPlayAudio(
        start: widget.data.audioStart,
        end: widget.data.audioEnd,
      );
    }
  }

  void _handleOptionTap(String option) {
    if (_isAnswered) return;

    final isCorrect = option == widget.data.correctAnswer;

    setState(() {
      _selectedOption = option;
      _isAnswered = true;
    });

    if (isCorrect) {
      widget.onCorrect();
    } else {
      widget.onWrong?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Split sentence by '___' to insert the blank
    final parts = widget.data.sentenceDisplay.split('___');

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
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

          // Sentence Display
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
                                : Colors.grey.shade400,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        _selectedOption ?? "       ",
                        style: TextStyle(
                          color: _isAnswered
                              ? (_selectedOption == widget.data.correctAnswer
                                    ? Colors.green
                                    : Colors.red)
                              : Colors.transparent, // Hide placeholder text
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

          const SizedBox(height: 48),

          // Options List (Vertical Cards like WordQuiz)
          Column(
            children: widget.data.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionCard(option, index),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String option, int index) {
    // Generate A, B, C, D labels
    final String label = String.fromCharCode(65 + index); // 65 is 'A'

    final isSelected = _selectedOption == option;
    final isCorrect = option == widget.data.correctAnswer;

    // Default Colors
    Color colorBg = Colors.white;
    Color colorBorder = Colors.grey.shade200;
    Color colorText = Colors.grey.shade700;
    Color colorLabelBg = Colors.grey.shade100;
    Color colorLabelText = Colors.grey.shade500;

    if (_isAnswered) {
      if (isSelected) {
        if (isCorrect) {
          // Selected Correct
          colorBg = Colors.green.shade50;
          colorBorder = Colors.green;
          colorText = Colors.green.shade900;
          colorLabelBg = Colors.green;
          colorLabelText = Colors.white;
        } else {
          // Selected Wrong
          colorBg = Colors.red.shade50;
          colorBorder = Colors.red;
          colorText = Colors.red.shade900;
          colorLabelBg = Colors.red;
          colorLabelText = Colors.white;
        }
      } else if (isCorrect) {
        // Unselected Correct (Reveal)
        colorBg = Colors.green.shade50;
        colorBorder = Colors.green;
        colorText = Colors.green.shade900;
        colorLabelBg = Colors.green;
        colorLabelText = Colors.white;
      }
    }

    return GestureDetector(
      onTap: () => _handleOptionTap(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorBorder, width: 2),
          boxShadow: [
            BoxShadow(
              color: !_isAnswered || !isSelected
                  ? Colors.black.withOpacity(0.05)
                  : colorBorder,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Label Box (A, B, C)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorLabelBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: colorLabelText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Option Text
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: colorText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
