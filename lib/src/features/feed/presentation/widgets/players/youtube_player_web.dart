import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YouTubePlayerWeb extends StatefulWidget {
  final String videoId;
  final bool isPlaying;
  final Function(double) onCurrentTime;
  final Function(bool) onStateChange;
  final VoidCallback onEnded;
  final Stream<double>? seekStream;
  final Function(String error)? onError;
  final double? start;
  final double? end;

  const YouTubePlayerWeb({
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
  State<YouTubePlayerWeb> createState() => _YouTubePlayerWebState();
}

class _YouTubePlayerWebState extends State<YouTubePlayerWeb> {
  late YoutubePlayerController _controller;
  // We use a polling timer because youtube_player_iframe doesn't stream position updates in value
  Timer? _positionTimer;
  late StreamSubscription<YoutubePlayerValue> _subscription;

  @override
  void initState() {
    super.initState();
    _initializeController();
    widget.seekStream?.listen((seconds) async {
      if (!mounted) return;
      _controller.seekTo(seconds: seconds, allowSeekAhead: true);
      // Wait a bit and force play if it was playing, to prevent pausing
      if (widget.isPlaying) {
        // Small delay to let the seek command process
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted && widget.isPlaying) {
            _controller.playVideo();
          }
        });
      }
    });
  }

  void _initializeController() {
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        loop: true,
        mute: true,
        enableJavaScript: true,
        pointerEvents: PointerEvents.none,
      ),
    );

    _controller.loadVideoById(videoId: widget.videoId);

    // Listen to state changes
    _subscription = _controller.listen((value) {
      if (!mounted) return;

      if (value.hasError) {
        widget.onError?.call(value.error.code.toString());
      }

      if (value.playerState == PlayerState.ended) {
        widget.onStateChange(false);
        widget.onEnded();
        _stopPositionTimer();
      } else if (value.playerState == PlayerState.playing) {
        widget.onStateChange(true);
        _startPositionTimer();
      } else if (value.playerState == PlayerState.paused ||
          value.playerState == PlayerState.unknown) {
        widget.onStateChange(false);
        _stopPositionTimer();
      }
    });

    // Initial check
    if (widget.isPlaying) {
      _startPositionTimer();
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (
      _,
    ) async {
      if (!mounted) return;
      final position = await _controller.currentTime;
      widget.onCurrentTime(position);

      // Segment loop logic
      if (widget.start != null && widget.end != null) {
        if (position >= widget.end!) {
          _controller.seekTo(seconds: widget.start!, allowSeekAhead: true);
        } else if (position < widget.start! - 2.0) {
          // Tolerance
          _controller.seekTo(seconds: widget.start!, allowSeekAhead: true);
        }
      }
    });
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  @override
  void didUpdateWidget(YouTubePlayerWeb oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle Video Change
    if (widget.videoId != oldWidget.videoId) {
      _controller.loadVideoById(videoId: widget.videoId);
    }

    // Handle Play/Pause from Parent
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.playVideo();
        _startPositionTimer();
      } else {
        _controller.pauseVideo();
        _stopPositionTimer();
      }
    }

    if (widget.start != oldWidget.start || widget.end != oldWidget.end) {
      // If start changed and we are ready, maybe seek to start?
      if (widget.start != null && widget.isPlaying) {
        _controller.seekTo(seconds: widget.start!, allowSeekAhead: true);
      }
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _subscription.cancel();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(controller: _controller, aspectRatio: 9 / 16);
  }
}
