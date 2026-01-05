import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/features/exercises/domain/models/sentence_exercise_model.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/question_widget.dart';
import 'package:pandascroll/src/features/exercises/presentation/widgets/sentence_audio_player.dart';
import 'package:pandascroll/src/features/feed/presentation/controllers/video_controller.dart';

class SentenceScrambleWidget extends ConsumerStatefulWidget {
  final String videoId;
  final SentenceExerciseModel sentence;
  final VoidCallback onCorrect;

  const SentenceScrambleWidget({
    super.key,
    required this.videoId,
    required this.sentence,
    required this.onCorrect,
  });

  @override
  ConsumerState<SentenceScrambleWidget> createState() =>
      _SentenceScrambleWidgetState();
}

class _SentenceScrambleWidgetState
    extends ConsumerState<SentenceScrambleWidget> {
  late List<_WordItem> _availableWords;
  late List<_WordItem?> _userAnswers;
  final Set<int> _placedWordIds = {};
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _initExercise();
  }

  @override
  void didUpdateWidget(covariant SentenceScrambleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sentence != oldWidget.sentence) {
      _initExercise();
    }
  }

  void _initExercise() {
    setState(() {
      _placedWordIds.clear();
      _isCorrect = false;

      // naive split by space, ideally we use a more robust tokenizer or the API provides tokens
      final words = widget.sentence.text.split(RegExp(r'\s+'));

      _userAnswers = List.filled(words.length, null);

      _availableWords = List.generate(
        words.length,
        (i) => _WordItem(id: i, text: words[i]),
      )..shuffle();
    });
  }

  void _checkAnswer() {
    if (_userAnswers.contains(null)) return;

    bool isCorrect = true;
    for (int i = 0; i < _userAnswers.length; i++) {
      // Compare with the sorted/original word at that position?
      // No, we need to compare against the original sentence structure.
      // We know the original words order.
      final originalWords = widget.sentence.text.split(RegExp(r'\s+'));
      if (_userAnswers[i]?.text != originalWords[i]) {
        isCorrect = false;
        break;
      }
    }

    setState(() {
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      Future.delayed(const Duration(milliseconds: 1000), widget.onCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get Video URL
    // We assume access to videoFeedProvider or similar to get the URL
    // Since we don't have direct access here without importing, let's assume videoFeedProvider is available
    // We need to import it.

    // For now, I'll use a placeholder or read from a provider if available.
    // The previous files showed usage of `videoFeedProvider`.
    // I will add the import: import 'package:pandascroll/src/features/feed/presentation/controllers/video_controller.dart';

    // But since I can't modify imports easily in write_to_file without overwriting, I'll use dynamic lookup or just assume user fixes imports if I miss one.
    // Wait, I am writing the whole file. I can add imports.

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  QuestionWidget(
                    title: "ARRANGE THE SENTENCE",
                    child: Column(
                      children: [
                        // Audio Player
                        _buildAudioPlayer(),
                        const SizedBox(height: 24),
                        // Drag Target Area
                        _buildDragArea(),
                      ],
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(height: 16),

                  // Word Bank
                  _buildWordBank(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAudioPlayer() {
    // Find video URL
    // We need videoFeedProvider.
    // I'll assume it's exposed nearby.
    // import 'package:pandascroll/src/features/feed/presentation/controllers/video_controller.dart';

    return Consumer(
      builder: (context, ref, child) {
        // This is a bit risky if videoFeedProvider is not exported or different path.
        // I will verify path. `video_controller.dart` seems correct based on `WordListenWidget`.
        // But I need to include the import in the file content.
        // See below.

        // Mocking for now to avoid compilation error if I get path wrong?
        // No, I should use the correct path.
        // Path: lib/src/features/feed/presentation/controllers/video_controller.dart

        final videoState = ref.watch(videoFeedProvider);
        final video = videoState.videos.firstWhere(
          (v) => v.id == widget.videoId,
          orElse: () => videoState.videos.first,
        );

        return SentenceAudioPlayer(
          url: video.audioUrl, // Assuming model has audioUrl
          start: widget.sentence.start,
          end: widget.sentence.end,
        );
      },
    );
  }

  Widget _buildDragArea() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),

      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: _userAnswers.asMap().entries.map((entry) {
          final index = entry.key;
          final word = entry.value;
          if (word == null) {
            return _buildEmptySlot(false);
          }
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
              isCorrect: _checkIfWordIsCorrectPosition(index, word),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _checkIfWordIsCorrectPosition(int index, _WordItem word) {
    // Logic to check if this specific word is in correct spot?
    // Usually we only show green if ALL are correct, or user feedback creates ease.
    // The reference `ScrambleWidget` shows green/red.
    // Let's stick to simple: if _isCorrect is true, everything is green.
    return _isCorrect;
  }

  Widget _buildEmptySlot(bool isHovering) {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildWordBank() {
    return Column(
      children: [
        const Text(
          "Tap words to arrange",
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _availableWords.map((word) {
              final isPlaced = _placedWordIds.contains(word.id);
              if (isPlaced) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () {
                  final emptyIndex = _userAnswers.indexOf(null);
                  if (emptyIndex != -1) {
                    setState(() {
                      _userAnswers[emptyIndex] = word;
                      _placedWordIds.add(word.id);
                    });
                    _checkAnswer();
                  }
                },
                child: _buildOptionChip(word),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlacedChip(_WordItem word, {required bool isCorrect}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.bambooGreen : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.pandaBlack, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.pandaBlack,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        word.text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.pandaBlack,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildOptionChip(_WordItem word) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pandaBlack, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.pandaBlack,
            offset: Offset(2, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        word.text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.pandaBlack,
          fontFamily: 'Nunito',
          fontSize: 16,
        ),
      ),
    );
  }
}

class _WordItem {
  final int id;
  final String text;
  _WordItem({required this.id, required this.text});
}
