import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../domain/models/exercise_model.dart';
import 'package:just_audio/just_audio.dart';

class ScrambleWidget extends StatefulWidget {
  final ScrambleData data;
  final VoidCallback onCorrect;
  final VoidCallback? onWrong;
  final String audioUrl;
  final Future<void> Function({required double start, required double end})
  onPlayAudio;
  final Future<void> Function() onPauseAudio;
  final Stream<PlayerState> audioStateStream;

  const ScrambleWidget({
    super.key,
    required this.data,
    required this.onCorrect,
    this.onWrong,
    required this.audioUrl,
    required this.onPlayAudio,
    required this.onPauseAudio,
    required this.audioStateStream,
  });

  // HTML Design Colors
  static const Color _surfaceDark = Color(0xFF1C2A33);

  @override
  State<ScrambleWidget> createState() => _ScrambleWidgetState();
}

class _ScrambleWidgetState extends State<ScrambleWidget> {
  late List<ScrambleWord> _availableWords;
  late List<ScrambleWord?> _userAnswers;

  // Track which original word ID is currently sitting in which answer slot
  final Set<int> _placedWordIds = {};

  bool _isCorrect = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Listen to parent stream
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

    _initExercise();
  }

  @override
  void didUpdateWidget(ScrambleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      // _audioPlayer.stop(); // Handled by parent or new stream event
      // We don't have control to stop parent audio here directly unless we pause.
      widget.onPauseAudio();
      _initExercise();
    }
  }

  void _initExercise() {
    // _initAudio(); // Removed
    setState(() {
      _placedWordIds.clear();
      _isCorrect = false;
      _userAnswers = List.filled(widget.data.words.length, null);

      final allWords = List.generate(
        widget.data.words.length,
        (i) => ScrambleWord(id: i, text: widget.data.words[i]),
      );
      allWords.shuffle();
      _availableWords = allWords;
    });
  }

  @override
  void dispose() {
    // _audioPlayer.dispose(); // Removed
    super.dispose();
  }

  Future<void> _playAudio() async {
    try {
      if (_isPlaying) {
        await widget.onPauseAudio();
      } else {
        await widget.onPlayAudio(
          start: widget.data.audioStart,
          end: widget.data.audioEnd,
        );
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void _checkAnswer() {
    if (_userAnswers.contains(null)) return;

    bool isCorrect = true;
    for (int i = 0; i < _userAnswers.length; i++) {
      if (_userAnswers[i]?.text != widget.data.words[i]) {
        isCorrect = false;
        break;
      }
    }

    setState(() {
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      widget.onCorrect();
    } else {
      // All slots filled but incorrect
      widget.onWrong?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Audio Header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: GestureDetector(
            onTap: _playAudio,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isPlaying
                        ? AppColors.bambooDark
                        : AppColors.bambooDark,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isPlaying ? "Listening..." : "Tap to listen",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ),

        DragTarget<ScrambleWord>(
          onWillAccept: (data) {
            // Only accept if there is an empty slot
            return _userAnswers.contains(null);
          },
          onAccept: (data) {
            // Find first empty slot
            final emptyIndex = _userAnswers.indexOf(null);
            if (emptyIndex != -1) {
              setState(() {
                _userAnswers[emptyIndex] = data;
                _placedWordIds.add(data.id);
              });
              _checkAnswer();
            }
          },
          builder: (context, candidateData, rejectedData) {
            final bool isHovering = candidateData.isNotEmpty;
            return Container(
              margin: const EdgeInsets.fromLTRB(0, 24, 0, 16),
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(minHeight: 140),
              decoration: BoxDecoration(
                color: isHovering ? Colors.grey.shade100 : Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: _isCorrect
                      ? AppColors.bambooGreen
                      : (isHovering
                            ? AppColors.primaryBrand
                            : ScrambleWidget._surfaceDark),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Stack(
                children: [
                  // Centered Hint Text
                  if (_userAnswers.every((e) => e == null))
                    const Positioned.fill(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.drag_indicator,
                              color: Colors.black26,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Drag words here",
                              style: TextStyle(
                                color: Colors.black26,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Slots Wrap: Only show filled slots
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.start,
                    children: List.generate(_userAnswers.length, (index) {
                      final word = _userAnswers[index];
                      if (word == null) {
                        return const SizedBox.shrink();
                      } else {
                        // Filled
                        final isCorrectPosition =
                            word.text == widget.data.words[index];
                        return GestureDetector(
                          onTap: () {
                            if (_isCorrect) return;
                            setState(() {
                              _userAnswers[index] = null;
                              _placedWordIds.remove(word.id);
                              _isCorrect = false;
                            });
                          },
                          child: _buildPlacedChip(
                            word,
                            isCorrect: isCorrectPosition,
                          ),
                        );
                      }
                    }),
                  ),
                ],
              ),
            );
          },
        ),

        const Spacer(),

        // Word Bank
        Container(
          margin: const EdgeInsets.only(top: 24),
          child: Center(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: _availableWords.map((word) {
                final isPlaced = _placedWordIds.contains(word.id);
                if (isPlaced) {
                  return const SizedBox.shrink();
                }

                return Draggable<ScrambleWord>(
                  data: word,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _buildOptionChip(word, isFeedback: true),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.0,
                    child: _buildOptionChip(word),
                  ),
                  child: _buildOptionChip(word),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPlacedChip(ScrambleWord word, {required bool isCorrect}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.bambooDark : Colors.redAccent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        word.text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildOptionChip(ScrambleWord word, {bool isFeedback = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ScrambleWidget._surfaceDark, // Using the dark surface color
        borderRadius: BorderRadius.circular(16),
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.2), width: 3),
        ),
      ),
      child: Text(
        word.text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
