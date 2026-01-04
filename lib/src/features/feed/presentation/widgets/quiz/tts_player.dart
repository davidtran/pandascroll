import 'package:flutter/material.dart';
import 'package:pandascroll/src/core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import 'word_audio_player.dart';

class TtsPlayer extends StatefulWidget {
  final String id;
  final String type; // 'video' | 'word' | 'sentence'
  final bool autoPlay;
  final double size;

  const TtsPlayer({
    super.key,
    required this.id,
    required this.type,
    this.autoPlay = false,
    this.size = 24,
  });

  @override
  State<TtsPlayer> createState() => _TtsPlayerState();
}

class _TtsPlayerState extends State<TtsPlayer> {
  String? _audioUrl;
  bool _isLoading = false;
  bool _hasError = false;

  Future<void> _fetchAudio() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await ApiClient.get(
        '/audio?id=${widget.id}&type=${widget.type}',
      );
      if (response['data'] != null) {
        final List<dynamic> list = response['data'];
        if (list.isNotEmpty) {
          final firstItem = list.first;
          final url = firstItem['url'] as String?;
          if (url != null && mounted) {
            setState(() {
              _audioUrl = url;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching audio: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we have a URL, show the actual player with autoplay if requested
    if (_audioUrl != null) {
      return WordAudioPlayer(url: _audioUrl, autoPlay: widget.autoPlay);
    }

    // Initial State or Loading
    return GestureDetector(
      onTap: _fetchAudio,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: _isLoading
            ? SizedBox(
                width: widget.size * 0.5,
                height: widget.size * 0.5,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Icon(
                Icons.volume_up_rounded,
                color: _hasError ? Colors.red : AppColors.textMain,
                size: widget.size,
              ),
      ),
    );
  }
}
