import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/core/utils/speech_scoring_service.dart';
import 'package:pandascroll/src/features/feed/domain/models/dictionary_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class WordSpeakWidget extends StatefulWidget {
  final DictionaryModel currentWord;
  final VoidCallback onCorrect;

  const WordSpeakWidget({
    super.key,
    required this.currentWord,
    required this.onCorrect,
  });

  @override
  State<WordSpeakWidget> createState() => _WordSpeakWidgetState();
}

class _WordSpeakWidgetState extends State<WordSpeakWidget> {
  final Record _audioRecorder = Record();
  bool _isRecording = false;
  bool _isProcessing = false;
  double? _score;
  String? _feedbackMessage;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WordSpeakWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWord != widget.currentWord) {
      setState(() {
        _score = null;
        _feedbackMessage = null;
        _isProcessing = false;
        _isRecording = false;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        String? path;
        if (!kIsWeb) {
          final directory = await getApplicationDocumentsDirectory();
          path = '${directory.path}/word_recording.m4a';
        }
        await _audioRecorder.start(path: path, encoder: AudioEncoder.aacLc);
        setState(() {
          _isRecording = true;
          _feedbackMessage = null;
          _score = null;
        });
      }
    } catch (e) {
      setState(() => _feedbackMessage = "Error starting: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        _processRecording(path);
      }
    } catch (e) {
      setState(() => _feedbackMessage = "Error stopping: $e");
    }
  }

  Future<void> _processRecording(String path) async {
    setState(() => _isProcessing = true);
    try {
      final text = await SpeechScoringService.transcribeAudio(path);
      final score = SpeechScoringService.calculateScore(
        text,
        widget.currentWord.word,
      );

      setState(() {
        _score = score;
      });

      if (score > 0.6) {
        // slightly lenient threshold
        Future.delayed(const Duration(seconds: 1), widget.onCorrect);
      } else {
        setState(() {
          _feedbackMessage = "Try again! You said: \"$text\"";
        });
      }
    } catch (e) {
      setState(() => _feedbackMessage = "Error processing: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color micColor = AppColors.primaryBrand;
    IconData micIcon = Icons.mic;

    if (_isRecording) {
      micColor = Colors.red;
      micIcon = Icons.stop;
    } else if (_isProcessing) {
      micColor = Colors.grey;
    } else if (_score != null && _score! > 0.6) {
      micColor = AppColors.bambooGreen;
      micIcon = Icons.check;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Tap and say the word",
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          widget.currentWord.word,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: AppColors.pandaBlack,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.currentWord.pronunciation,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 48),

        GestureDetector(
          onTap: _isProcessing ? null : _toggleRecording,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: micColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.pandaBlack, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.pandaBlack,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : Icon(micIcon, size: 48, color: Colors.white),
          ),
        ),

        if (_feedbackMessage != null) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _feedbackMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red, // Or dynamic based on error vs feedback
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],

        // Skip button if stuck
        const Spacer(),
        TextButton(
          onPressed: widget.onCorrect,
          child: const Text("Skip", style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
