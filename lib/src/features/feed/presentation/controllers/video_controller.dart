import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/video_model.dart';
import '../providers/video_translations_provider.dart';

class VideoFeedState {
  final List<VideoModel> videos;
  final int currentIndex;
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;

  VideoFeedState({
    required this.videos,
    required this.currentIndex,
    this.isLoading = false,
    this.isFetchingMore = false,
    this.error,
  });

  VideoFeedState copyWith({
    List<VideoModel>? videos,
    int? currentIndex,
    bool? isLoading,
    bool? isFetchingMore,
    String? error,
  }) {
    return VideoFeedState(
      videos: videos ?? this.videos,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
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

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final List<dynamic> data =
          (await Supabase.instance.client.rpc(
            'get_recommended_feed',
            params: {'p_user_id': userId, 'p_limit': 10},
          )) ??
          [];

      final videos = data.map((json) => VideoModel.fromJson(json)).toList();
      state = state.copyWith(videos: videos, isLoading: false);

      // Pre-fetch translations for the first 3 videos
      for (int i = 0; i < videos.length && i < 3; i++) {
        ref.read(videoTranslationsProvider(videos[i].id).future);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchMoreVideos() async {
    if (state.isFetchingMore || state.isLoading) return;

    try {
      state = state.copyWith(isFetchingMore: true);

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final List<dynamic> data =
          (await Supabase.instance.client.rpc(
            'get_recommended_feed',
            params: {'p_user_id': userId, 'p_limit': 10},
          )) ??
          [];

      final newVideos = data.map((json) => VideoModel.fromJson(json)).toList();
      final currentVideos = state.videos;

      // Filter out duplicates just in case
      final ids = currentVideos.map((v) => v.id).toSet();
      final uniqueNewVideos = newVideos
          .where((v) => !ids.contains(v.id))
          .toList();

      state = state.copyWith(
        videos: [...currentVideos, ...uniqueNewVideos],
        isFetchingMore: false,
      );
    } catch (e) {
      // Silently fail for background fetch, or log it
      state = state.copyWith(isFetchingMore: false);
    }
  }

  void onPageChanged(int index) {
    state = state.copyWith(currentIndex: index);

    final videos = state.videos;

    // Translation Preloading: Index + 2 Sliding Window
    if (index + 2 < videos.length) {
      ref.read(videoTranslationsProvider(videos[index + 2].id).future);
    }

    // Feed Preloading: Trigger when 5 items away from end
    if (videos.length - index <= 5) {
      fetchMoreVideos();
    }
  }
}

final videoFeedProvider =
    NotifierProvider.autoDispose<VideoFeedController, VideoFeedState>(
      VideoFeedController.new,
    );
