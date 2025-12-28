import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/api_client.dart';

class StatsRepository {
  final SupabaseClient _supabase;

  StatsRepository(this._supabase);

  Future<void> updateUserVideoStats({
    required String videoId,
    double? viewDuration,
    bool? liked,
    DateTime? lastViewedAt,
    double? exerciseScores,
    double? totalExercises,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final updates = {
      'user_id': userId,
      'video_id': videoId,
      if (viewDuration != null) 'view_duration': viewDuration,
      if (liked != null) 'liked': liked,
      if (lastViewedAt != null)
        'last_viewed_at': lastViewedAt.toIso8601String(),
      if (exerciseScores != null) 'exercise_scores': exerciseScores,
      if (totalExercises != null) 'total_exercises': totalExercises,
    };

    try {
      await _supabase
          .from('user_video_stats')
          .upsert(updates, onConflict: 'user_id, video_id');
    } catch (e) {
      // Create table if not exists logic is handled by backend usually, just log error
      print('Error updating user video stats: $e');
    }
  }

  Future<Map<String, dynamic>?> addXp({
    required String event,
    double? value,
    String? videoId,
  }) async {
    try {
      final response = await ApiClient.post(
        '/add_xp',
        body: {
          'event': event,
          if (value != null) 'value': value,
          if (videoId != null) 'video_id': videoId,
        },
      );
      // Response: { xp: newXp, level: newLevel, remain_xp: remainXp }
      return response;
    } catch (e) {
      print('Error adding XP: $e');
      return null;
    }
  }

  Future<void> insertExerciseResult({
    required double score,
    required double totalQuestions,
    required double durationSeconds,
    String? videoId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final insertData = {
      'user_id': userId,
      'score': score,
      'total_questions': totalQuestions,
      'duration_seconds': durationSeconds,
      if (videoId != null) 'video_id': videoId,
    };

    try {
      await _supabase.from('video_exercise_results').insert(insertData);
    } catch (e) {
      print('Error inserting exercise result: $e');
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return {};

    try {
      final response = await _supabase.rpc(
        'get_user_stats',
        params: {'target_user_id': userId},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching user stats: $e');
      return {};
    }
  }
}
