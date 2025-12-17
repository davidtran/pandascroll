import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/video_model.dart';

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
  static const String _backendUrl = 'https://api-panda.studyfoc.us';

  @override
  VideoFeedState build() {
    // Start fetching immediately
    Future.microtask(() => fetchVideos());

    return VideoFeedState(videos: [], currentIndex: 0, isLoading: true);
  }

  Future<void> fetchVideos() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final session = Supabase.instance.client.auth.currentSession;
      final token = session?.accessToken;

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('$_backendUrl/feed'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> videoList = data['data'];
        final videos = videoList
            .map((json) => VideoModel.fromJson(json))
            .toList();

        state = state.copyWith(videos: videos, isLoading: false);
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
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
