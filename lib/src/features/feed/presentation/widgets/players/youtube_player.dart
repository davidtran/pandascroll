import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/players/custom_youtube_player.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/players/youtube_player_web.dart';

class YouTubePlayer extends StatelessWidget {
  final String videoId;
  final bool isPlaying;
  final Function(double) onCurrentTime;
  final Function(bool) onStateChange;
  final VoidCallback onEnded;
  final Function(String error)? onError;
  final Stream<double>? seekStream;
  final double? start;
  final double? end;

  const YouTubePlayer({
    super.key,
    required this.videoId,
    required this.isPlaying,
    required this.onCurrentTime,
    required this.onStateChange,
    required this.onEnded,
    this.onError,
    this.seekStream,
    this.start,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return YouTubePlayerWeb(
        videoId: videoId,
        isPlaying: isPlaying,
        onCurrentTime: onCurrentTime,
        onStateChange: onStateChange,
        onEnded: onEnded,
        onError: onError,
        seekStream: seekStream,
        start: start,
        end: end,
      );
    }
    return CustomYouTubePlayerMobile(
      videoId: videoId,
      isPlaying: isPlaying,
      onCurrentTime: onCurrentTime,
      onStateChange: onStateChange,
      onEnded: onEnded,
      onError: onError,
      seekStream: seekStream,
      start: start,
      end: end,
    );
  }
}
