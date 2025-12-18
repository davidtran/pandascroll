import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/video_model.dart';
import '../../../../core/network/api_client.dart';

class VideoFeedState {
  final List<VideoModel> videos;
  final int currentIndex;
  final bool isLoading;
  final String? error;

  VideoFeedState({
    required this.videos,
    required this.currentIndex,
    this.isLoading = false,
    this.error,
  });

  VideoFeedState copyWith({
    List<VideoModel>? videos,
    int? currentIndex,
    bool? isLoading,
    String? error,
  }) {
    return VideoFeedState(
      videos: videos ?? this.videos,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class VideoFeedController extends Notifier<VideoFeedState> {
  @override
  VideoFeedState build() {
    // Start fetching immediately
    Future.microtask(() => fetchVideos());

    return VideoFeedState(videos: [], currentIndex: 0, isLoading: true);
  }

  Future<void> fetchVideos() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final data = await ApiClient.get('/feed');
      final List<dynamic> videoList = data['data'];
      final videos = videoList
          .map((json) => VideoModel.fromJson(json))
          .toList();

      state = state.copyWith(videos: videos, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void onPageChanged(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

final videoFeedProvider = NotifierProvider<VideoFeedController, VideoFeedState>(
  VideoFeedController.new,
);
