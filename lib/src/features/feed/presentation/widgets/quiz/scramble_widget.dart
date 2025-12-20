import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../domain/models/exercise_model.dart';

import 'package:just_audio/just_audio.dart';

class ScrambleWidget extends StatefulWidget {
  final ScrambleData data;
  final VoidCallback onCorrect;
  final String audioUrl;

  const ScrambleWidget({
    super.key,
    required this.data,
    required this.onCorrect,
    required this.audioUrl,
  });

  @override
  State<ScrambleWidget> createState() => _ScrambleWidgetState();
}

class _ScrambleWidgetState extends State<ScrambleWidget> {
  late List<ScrambleWord> _availableWords;
  late List<ScrambleWord?> _userAnswers;
  final Set<int> _usedWordIds = {};

  bool _isCorrect = false;
  bool _hasChecked = false;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

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

    _initExercise();
  }

  @override
  void didUpdateWidget(ScrambleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _audioPlayer.stop();
      _initExercise();
    }
  }

  void _initExercise() {
    _initAudio();

    setState(() {
      _usedWordIds.clear();
      _isCorrect = false;
      _hasChecked = false;
      _isPlaying = false;

      // Initialize user answers with nulls (empty slots)
      _userAnswers = List.filled(widget.data.words.length, null);

      // Create ScrambleWord objects from the correct words list
      final allWords = List.generate(
        widget.data.words.length,
        (i) => ScrambleWord(id: i, text: widget.data.words[i]),
      );

      allWords.shuffle();
      _availableWords = allWords;
    });
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
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    }
  }

  void _handleAvailableWordTap(ScrambleWord word) {
    if (_isCorrect || _usedWordIds.contains(word.id)) return;

    // Find first empty slot
    final emptyIndex = _userAnswers.indexOf(null);
    if (emptyIndex != -1) {
      setState(() {
        _userAnswers[emptyIndex] = word;
        _usedWordIds.add(word.id);
        _hasChecked = false;
      });

      _checkAnswer();
    }
  }

  void _handleSlotTap(int index) {
    if (_isCorrect) return;

    final word = _userAnswers[index];
    if (word != null) {
      setState(() {
        _userAnswers[index] = null;
        _usedWordIds.remove(word.id);
        _hasChecked = false;
      });
    }
  }

  void _checkAnswer() {
    // Check if all slots are filled
    if (_userAnswers.contains(null)) {
      // Maybe show a message "Please fill all blanks"
      return;
    }

    bool isCorrect = true;
    for (int i = 0; i < _userAnswers.length; i++) {
      if (_userAnswers[i]!.text != widget.data.words[i]) {
        isCorrect = false;
        break;
      }
    }

    setState(() {
      _isCorrect = isCorrect;
      _hasChecked = true;
    });

    if (isCorrect) {
      Future.delayed(const Duration(milliseconds: 1000), widget.onCorrect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Audio Button
        GestureDetector(
          onTap: _playAudio,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
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
        const SizedBox(height: AppSpacing.xl),

        // Answer Slots Area (Dashes)
        Wrap(
          spacing: 8,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: List.generate(_userAnswers.length, (index) {
            final word = _userAnswers[index];
            return GestureDetector(
              onTap: () => _handleSlotTap(index),
              child: _buildSlot(word, index),
            );
          }),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Available Words Area
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: 8,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _availableWords
                .map((word) => _buildOptionChip(word))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSlot(ScrambleWord? word, int index) {
    final isFilled = word != null;

    // If checked and incorrect, show red. If correct, show green.
    Color textColor = AppColors.textMain;
    Color underlineColor = Colors.grey.shade400;

    if (_hasChecked && isFilled) {
      if (_isCorrect) {
        textColor = Colors.green;
        underlineColor = Colors.green;
      } else {
        // We could check individual words if we wanted,
        // but for now just mark whole sentence as wrong/right
        textColor = Colors.red;
        underlineColor = Colors.red;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: underlineColor, width: 2)),
      ),
      child: Text(
        word?.text ?? "       ", // Spaces for empty slot width
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isFilled ? textColor : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildOptionChip(ScrambleWord word) {
    final isUsed = _usedWordIds.contains(word.id);

    return GestureDetector(
      onTap: () => _handleAvailableWordTap(word),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isUsed ? 0.3 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: [
              if (!isUsed)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
            border: Border.all(color: AppColors.primaryBrand.withOpacity(0.2)),
          ),
          child: Text(
            word.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}
