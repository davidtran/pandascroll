import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoFeedState {
  final List<String> videos;
  final int currentIndex;

  VideoFeedState({
    required this.videos,
    required this.currentIndex,
  });

  VideoFeedState copyWith({
    List<String>? videos,
    int? currentIndex,
  }) {
    return VideoFeedState(
      videos: videos ?? this.videos,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class VideoFeedController extends Notifier<VideoFeedState> {
  @override
  VideoFeedState build() {
    return VideoFeedState(
      videos: [
        '7580625042531224839',
        '7578736921954782482',
        '7573540203902553362',
      ],
      currentIndex: 0,
    );
  }

  void onPageChanged(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

final videoFeedProvider = NotifierProvider<VideoFeedController, VideoFeedState>(VideoFeedController.new);
