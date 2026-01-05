import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class VideoPlayerControlState {
  final double? start;
  final double? end;
  final bool loop;
  final bool shouldPlay;

  const VideoPlayerControlState({
    this.start,
    this.end,
    this.loop = false,
    this.shouldPlay = false,
  });

  VideoPlayerControlState copyWith({
    double? start,
    double? end,
    bool? loop,
    bool? shouldPlay,
  }) {
    return VideoPlayerControlState(
      start: start ?? this.start,
      end: end ?? this.end,
      loop: loop ?? this.loop,
      shouldPlay: shouldPlay ?? this.shouldPlay,
    );
  }
}

class VideoPlayerControlNotifier
    extends StateNotifier<VideoPlayerControlState> {
  VideoPlayerControlNotifier() : super(const VideoPlayerControlState());

  void setSegment({
    required double start,
    required double end,
    bool loop = true,
  }) {
    state = VideoPlayerControlState(start: start, end: end, loop: loop);
  }

  Future<void> playSegment({required double start, required double end}) async {
    state = VideoPlayerControlState(
      start: start,
      end: end,
      loop: false,
      shouldPlay: true,
    );

    final duration = (end - start).abs();
    await Future.delayed(Duration(milliseconds: (duration * 1000).toInt()));

    if (mounted) {
      clearSegment();
    }
  }

  void clearSegment() {
    state = const VideoPlayerControlState();
  }
}

final videoPlayerControlProvider =
    StateNotifierProvider.family<
      VideoPlayerControlNotifier,
      VideoPlayerControlState,
      String
    >((ref, id) {
      return VideoPlayerControlNotifier();
    });
