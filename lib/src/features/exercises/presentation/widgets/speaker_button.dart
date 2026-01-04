import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';
import 'package:pandascroll/src/core/utils/speech_scoring_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class SpeakerButton extends StatefulWidget {
  final String targetWord;
  final Function(double score) onScored;

  const SpeakerButton({
    super.key,
    required this.targetWord,
    required this.onScored,
  });

  @override
  State<SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends State<SpeakerButton>
    with SingleTickerProviderStateMixin {
  Record? _audioRecorder;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _audioRecorder?.dispose();
    _pulseController.dispose();
    super.dispose();
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
      _audioRecorder = Record();
      if (await _audioRecorder!.hasPermission()) {
        String? path;
        if (!kIsWeb) {
          final directory = await getApplicationDocumentsDirectory();
          path = '${directory.path}/word_recording.m4a';
        }
        await _audioRecorder!.start(path: path, encoder: AudioEncoder.aacLc);
        setState(() => _isRecording = true);
        _pulseController.repeat(reverse: true);
      }
    } catch (e) {
      debugPrint("Error starting: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder?.stop();
      setState(() => _isRecording = false);
      _pulseController.stop();
      _pulseController.reset();
      await _audioRecorder?.dispose();
      _audioRecorder = null;

      if (path != null) {
        _processRecording(path);
      }
    } catch (e) {
      debugPrint("Error stopping: $e");
    }
  }

  Future<void> _processRecording(String path) async {
    setState(() => _isProcessing = true);
    try {
      final text = await SpeechScoringService.transcribeAudio(
        path,
        hint: widget.targetWord,
      );
      final score = SpeechScoringService.calculateScore(
        text,
        widget.targetWord,
      );

      widget.onScored(score);
    } catch (e) {
      debugPrint("Error processing: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDown = _isPressed || _isRecording;
    final double offsetX = isDown ? 4.0 : 0.0;
    final double offsetY = isDown ? 6.0 : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: _isProcessing ? null : _toggleRecording,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse Effect (Behind)
              if (_isRecording)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),

              // Main Button with Physical Press Effect
              Transform.translate(
                offset: Offset(offsetX, offsetY),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.pandaBlack, width: 3),
                    boxShadow: isDown
                        ? []
                        : [
                            const BoxShadow(
                              color: AppColors.pandaBlack,
                              offset: Offset(4, 6),
                              blurRadius: 0,
                            ),
                          ],
                  ),
                  child: Center(
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isRecording
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                                size: 48,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isRecording ? "Tap again to stop" : "Tap to speak",
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.pandaBlack,
          ),
        ),
        const SizedBox(height: 24),
        // Simulated Audio Visualizer
        if (_isRecording || _isProcessing)
          SizedBox(
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200 + index * 100),
                  width: 6,
                  height: _isRecording ? 16.0 + (index % 3) * 8 : 4.0,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.pandaBlack,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
