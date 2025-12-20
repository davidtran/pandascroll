import 'dart:math';
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
  final String audioUrl;

  const ParrotWidget({
    super.key,
    required this.data,
    required this.onCorrect,
    required this.audioUrl,
  });

  @override
  State<ParrotWidget> createState() => _ParrotWidgetState();
}

class _ParrotWidgetState extends State<ParrotWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
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
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      if (widget.data.audioStart < widget.data.audioEnd) {
        await _audioPlayer.setAudioSource(
          ClippingAudioSource(
            start: Duration(
              milliseconds: (widget.data.audioStart * 1000).toInt(),
            ),
            end: Duration(milliseconds: (widget.data.audioEnd * 1000).toInt()),
            child: AudioSource.uri(Uri.parse(widget.audioUrl)),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error initializing audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      setState(() => _isPlaying = false);
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
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/recording.m4a';

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
      final score = _calculateScore(text, widget.data.sentenceText);

      setState(() {
        _transcribedText = text;
        _score = score;
      });
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
                size: 48,
                color: AppColors.primaryBrand,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              widget.data.sentenceText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
              textAlign: TextAlign.center,
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
                  color: (_isRecording ? Colors.red : AppColors.primaryBrand)
                      .withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        if (_isProcessing)
          const CircularProgressIndicator(color: AppColors.primaryBrand),

        if (_transcribedText != null) ...[
          const SizedBox(height: AppSpacing.md),

          if (_score != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Score: ${(_score! * 100).toInt()}%",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _score! > 0.8 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: widget.onCorrect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],

        if (_feedbackMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Text(
              _feedbackMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
