import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../domain/models/exercise_model.dart';

class ParrotWidget extends StatefulWidget {
  final ParrotData data;
  final VoidCallback onCorrect;
  final VoidCallback? onWrong;
  final String audioUrl;

  const ParrotWidget({
    super.key,
    required this.data,
    required this.onCorrect,
    required this.onWrong,
    required this.audioUrl,
    required this.onPlayAudio,
    required this.onPauseAudio,
    required this.audioStateStream,
  });
  final Future<void> Function({required double start, required double end})
  onPlayAudio;
  final Future<void> Function() onPauseAudio;
  final Stream<PlayerState> audioStateStream;

  @override
  State<ParrotWidget> createState() => _ParrotWidgetState();
}

class _ParrotWidgetState extends State<ParrotWidget> {
  // final AudioPlayer _audioPlayer = AudioPlayer(); // Removed
  final Record _audioRecorder = Record();

  bool _isPlaying = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _transcribedText;
  double? _score;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    // _initAudio(); // Removed
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
  void didUpdateWidget(ParrotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _resetState();
      // _initAudio(); // Removed
    }
  }

  void _resetState() {
    setState(() {
      _isRecording = false;
      _isProcessing = false;
      _transcribedText = null;
      _score = null;
      _feedbackMessage = null;
      // _isPlaying handled by stream
    });
    // _audioPlayer.stop(); // Handled by parent pause if needed
    widget.onPauseAudio();
  }

  // Future<void> _initAudio() async { ... } // Removed

  @override
  void dispose() {
    // _audioPlayer.dispose(); // Removed
    _audioRecorder.dispose();
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

  Future<void> _toggleRecording() async {
    // Stop audio if recording starts
    if (!_isRecording) {
      await widget.onPauseAudio();
    }

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
          path = '${directory.path}/recording.m4a';
        }
        // On Web, path is ignored/handled by browser (returns blob URL on stop)

        await _audioRecorder.start(path: path, encoder: AudioEncoder.aacLc);
        setState(() {
          _isRecording = true;
          _transcribedText = null;
          _score = null;
          _feedbackMessage = null;
        });
      }
    } catch (e) {
      debugPrint("Error starting recording: $e");
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
      debugPrint("Error stopping recording: $e");
    }
  }

  Future<void> _processRecording(String path) async {
    setState(() => _isProcessing = true);

    try {
      final data = await ApiClient.upload(
        '/transcribe',
        filePath: path,
        fieldName: 'file',
        contentType: 'audio/m4a',
      );

      final text = data['text'] as String? ?? '';
      _transcribedText = text; // Store for debugging/display if needed
      final score = _calculateScore(text, widget.data.sentenceText);
      _score = score;

      print('score: $score');

      if (score > 0.5) {
        widget.onCorrect();
      } else {
        widget.onWrong?.call();
      }
    } catch (e) {
      setState(() {
        _feedbackMessage = "Error: $e";
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  double _calculateScore(String transcribed, String original) {
    if (original.isEmpty) return 0.0;

    final normalizedTranscribed = transcribed.toLowerCase().trim();
    final normalizedOriginal = original.toLowerCase().trim();

    if (normalizedTranscribed.isEmpty) return 0.0;

    final distance = _levenshtein(normalizedTranscribed, normalizedOriginal);
    final maxLength = max(
      normalizedTranscribed.length,
      normalizedOriginal.length,
    );

    if (maxLength == 0) return 1.0;

    return 1.0 - (distance / maxLength);
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i++) v0[i] = i;

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < t.length + 1; j++) v0[j] = v1[j];
    }

    return v1[t.length];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _playAudio,
              icon: Icon(
                _isPlaying
                    ? Icons.stop_circle_rounded
                    : Icons.volume_up_rounded,
                size: 32,
                color: AppColors.pandaBlack,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Flexible(
              child: Text(
                widget.data.sentenceText,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // Microphone Button
        GestureDetector(
          onTap: _toggleRecording,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red : AppColors.primaryBrand,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? Colors.red : AppColors.textLight)
                      .withOpacity(0.3),
                  blurRadius: 0,
                  offset: const Offset(0, 2),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    size: 48,
                    color: Colors.white,
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tap to speak',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
        ),
      ],
    );
  }
}
