import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  const YouTubePlayer({
    super.key,
    required this.videoId,
    required this.isPlaying,
    required this.onCurrentTime,
    required this.onStateChange,
    required this.onEnded,
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
      );
    } else {
      return YouTubePlayerMobile(
        videoId: videoId,
        isPlaying: isPlaying,
        onCurrentTime: onCurrentTime,
        onStateChange: onStateChange,
        onEnded: onEnded,
      );
    }
  }
}
