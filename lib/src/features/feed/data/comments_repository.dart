import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/features/feed/domain/models/comment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsRepository {
  final SupabaseClient _client;

  CommentsRepository(this._client);

  Future<List<CommentModel>> getComments(String videoId) async {
    try {
      final response = await _client
          .from('video_comments')
          .select('*, profiles(username, avatar_url)')
          .eq('video_id', videoId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<CommentModel?> addComment({
    required String videoId,
    required String content,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('video_comments')
          .insert({'user_id': user.id, 'video_id': videoId, 'content': content})
          .select('*, profiles(username, avatar_url)')
          .single();

      return CommentModel.fromJson(response);
    } catch (e) {
      print('Error adding comment: $e');
      return null;
    }
  }
}

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  return CommentsRepository(Supabase.instance.client);
});
