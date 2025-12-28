import 'package:flutter/material.dart';

class PlayControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onRewind;
  final VoidCallback onForward;

  const PlayControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onRewind,
    required this.onForward,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildControlButton(Icons.replay_5_rounded, onRewind, "Rewind 5s"),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            padding: const EdgeInsets.all(0),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildControlButton(Icons.forward_5_rounded, onForward, "Forward 5s"),
      ],
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onTap,
    String tooltip,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Icon(
          icon,
          color: Colors.white,
          size: 16,
          shadows: const [
            Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
      ),
    );
  }
}
