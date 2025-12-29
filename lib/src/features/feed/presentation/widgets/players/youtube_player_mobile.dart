import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerMobile extends StatefulWidget {
  final String videoId;
  final bool isPlaying;
  final Function(double) onCurrentTime;
  final Function(bool) onStateChange;
  final VoidCallback onEnded;
  final Stream<int>? seekStream;

  const YouTubePlayerMobile({
    super.key,
    required this.videoId,
    required this.isPlaying,
    required this.onCurrentTime,
    required this.onStateChange,
    required this.onEnded,
    this.seekStream,
  });

  @override
  State<YouTubePlayerMobile> createState() => _YouTubePlayerMobileState();
}

class _YouTubePlayerMobileState extends State<YouTubePlayerMobile> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  StreamSubscription? _seekSubscription;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _seekSubscription = widget.seekStream?.listen((seconds) {
      if (_isPlayerReady && mounted) {
        final currentPos = _controller.value.position;
        final newPos = currentPos + Duration(seconds: seconds);
        _controller.seekTo(newPos);
      }
    });
  }

  void _initializeController() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideControls: true,
        disableDragSeek: true,
        loop: true,
        isLive: false,
        forceHD: false,
        enableCaption: false,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      widget.onCurrentTime(_controller.value.position.inMilliseconds / 1000);

      if (_controller.value.playerState == PlayerState.ended) {
        widget.onEnded();
      }

      // Update playing state based on player state
      final isPlaying = _controller.value.isPlaying;
      if (widget.isPlaying != isPlaying) {
        // We usually want to notify parent if state changes internally (e.g. buffering).
        widget.onStateChange(isPlaying);
      }
    }
  }

  @override
  void didUpdateWidget(YouTubePlayerMobile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle Video Change
    if (widget.videoId != oldWidget.videoId) {
      _controller.load(widget.videoId);
    }

    // Handle Play/Pause from Parent
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _seekSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: false,
      onReady: () {
        _isPlayerReady = true;
        if (widget.isPlaying) {
          _controller.play();
        }
      },
      onEnded: (data) {
        widget.onEnded();
      },
    );
  }
}
