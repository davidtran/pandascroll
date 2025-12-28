import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../../core/theme/app_colors.dart';

class WordAudioPlayer extends StatefulWidget {
  final String? url;
  final bool autoPlay;

  const WordAudioPlayer({super.key, required this.url, this.autoPlay = false});

  @override
  State<WordAudioPlayer> createState() => _WordAudioPlayerState();
}

class _WordAudioPlayerState extends State<WordAudioPlayer> {
  late AudioPlayer _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    if (widget.url == null) return;

    try {
      await _player.setUrl(widget.url!);
      if (widget.autoPlay && mounted) {
        _play();
      }
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  Future<void> _play() async {
    if (_isPlaying || widget.url == null) return;

    setState(() {
      _isPlaying = true;
    });

    try {
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      debugPrint("Error playing audio: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url == null) return const SizedBox();

    return GestureDetector(
      onTap: _play,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isPlaying
              ? AppColors.primaryBrand.withOpacity(0.2)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.volume_up_rounded,
          color: _isPlaying ? AppColors.primaryBrand : Colors.grey[600],
          size: 24,
        ),
      ),
    );
  }
}
