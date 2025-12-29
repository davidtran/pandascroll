import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoStatusRepositoryProvider = Provider<VideoStatusRepository>((ref) {
  return VideoStatusRepository(ref);
});

final blockedVideosProvider = StateProvider<Set<String>>((ref) => {});

class VideoStatusRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Ref _ref;

  VideoStatusRepository(this._ref);

  Future<void> logVideoError(String videoId, String status) async {
    // Add to local blocked list immediately
    _ref
        .read(blockedVideosProvider.notifier)
        .update((state) => {...state, videoId});

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('video_status').upsert({
        'video_id': videoId,
        'user_id': userId,
        'status': status,
      }, onConflict: 'video_id,user_id');
    } catch (e) {
      // Fail silently or log to analytic service, don't crash app
      print('Error logging video status: $e');
    }
  }
}
