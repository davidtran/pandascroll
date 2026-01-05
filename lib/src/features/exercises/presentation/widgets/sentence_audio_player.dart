import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pandascroll/src/core/theme/app_colors.dart';

class SentenceAudioPlayer extends StatefulWidget {
  final String url;
  final double start;
  final double end;
  final bool autoPlay;

  const SentenceAudioPlayer({
    super.key,
    required this.url,
    required this.start,
    required this.end,
    this.autoPlay = true,
  });

  @override
  State<SentenceAudioPlayer> createState() => _SentenceAudioPlayerState();
}

class _SentenceAudioPlayerState extends State<SentenceAudioPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(covariant SentenceAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.start != widget.start ||
        oldWidget.end != widget.end) {
      _initPlayer();
    }
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.url.isEmpty) return;

      // Stop previous playback
      await _audioPlayer.stop();
      _playerStateSubscription?.cancel();

      // Convert seconds to milliseconds for Duration
      final startMs = (widget.start * 1000).toInt();
      final endMs = (widget.end * 1000).toInt();

      final source = ClippingAudioSource(
        start: Duration(milliseconds: startMs),
        end: Duration(milliseconds: endMs),
        child: AudioSource.uri(Uri.parse(widget.url)),
      );

      await _audioPlayer.setAudioSource(source);
      await _audioPlayer.setLoopMode(LoopMode.off);

      if (widget.autoPlay) {
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Error initializing audio player: $e");
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.pandaBlack, width: 2),
      ),
      child: IconButton(
        icon: StreamBuilder<PlayerState>(
          stream: _audioPlayer.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;

            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.pandaBlack,
                ),
              );
            } else if (playing != true ||
                processingState == ProcessingState.completed) {
              return const Icon(
                Icons.play_arrow_rounded,
                size: 32,
                color: AppColors.pandaBlack,
              );
            } else {
              return const Icon(
                Icons.pause_rounded,
                size: 32,
                color: AppColors.pandaBlack,
              );
            }
          },
        ),
        onPressed: () async {
          final playerState = _audioPlayer.playerState;
          final processingState = playerState.processingState;
          final playing = playerState.playing;
          print('$playerState');

          if (processingState == ProcessingState.completed || !playing) {
            print('play');
            await _audioPlayer.seek(Duration.zero);
            _audioPlayer.play();
          } else {
            print('pause');
            await _audioPlayer.pause();
          }
        },
      ),
    );
  }
}
