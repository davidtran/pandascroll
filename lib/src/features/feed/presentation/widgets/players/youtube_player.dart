import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pandascroll/src/features/feed/presentation/widgets/players/custom_youtube_player.dart';

// Conditionally import the correct implementation?
// Or just import both and switch at runtime (assuming packages don't conflict at compile time).
// Since both are normal packages, we can import them.
import 'youtube_player_mobile.dart';
import 'youtube_player_web.dart';

class YouTubePlayer extends StatelessWidget {
  final String videoId;
  final bool isPlaying;
  final Function(double) onCurrentTime;
  final Function(bool) onStateChange;
  final VoidCallback onEnded;
  final Function(String error)? onError;
  final Stream<double>? seekStream;

  const YouTubePlayer({
    super.key,
    required this.videoId,
    required this.isPlaying,
    required this.onCurrentTime,
    required this.onStateChange,
    required this.onEnded,
    this.onError,
    this.seekStream,
  });

  @override
  Widget build(BuildContext context) {
    return CustomYouTubePlayerMobile(
      videoId: videoId,
      isPlaying: isPlaying,
      onCurrentTime: onCurrentTime,
      onStateChange: onStateChange,
      onEnded: onEnded,
      onError: onError,
      seekStream: seekStream,
    );
  }
}
