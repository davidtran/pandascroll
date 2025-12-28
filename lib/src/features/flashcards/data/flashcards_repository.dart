import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/flashcard_model.dart';

class FlashcardsRepository {
  final SupabaseClient _supabase;

  FlashcardsRepository(this._supabase);

  Future<void> addFlashcard({
    required String front,
    required List<String> back,
    String? videoId,
    double? startTime,
    double? endTime,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // "back is actually an array of text" - storing as JSON string if column is text
    // If column is text[] in postgres, supabase handles List<String> automatically usually,
    // but user provided `back text null`. So I'll encode it.

    await _supabase.from('flashcards').insert({
      'user_id': user.id,
      'video_id': videoId,
      'video_timestamp_start': startTime,
      'video_timestamp_end': endTime,
      'type': 'word',
      'front': front,
      'back': back,
      'status': 'new',
      'step': 0,
      'interval': 0,
      'ease_factor': 2.5,
      'next_review_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<FlashcardModel>> getDueFlashcards() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('flashcards')
        .select()
        .eq('user_id', user.id)
        .lte('next_review_at', DateTime.now().toIso8601String())
        .order('next_review_at', ascending: true)
        .limit(20);

    return (response as List).map((e) => FlashcardModel.fromJson(e)).toList();
  }

  Future<int> getDueFlashcardsCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    final response = await _supabase
        .from('flashcards')
        .count(CountOption.exact)
        .eq('user_id', user.id)
        .lte('next_review_at', DateTime.now().toIso8601String());

    return response;
  }

  Future<int> getTotalFlashcardsCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    final response = await _supabase
        .from('flashcards')
        .count(CountOption.exact)
        .eq('user_id', user.id);

    return response;
  }

  Future<void> updateFlashcardReview(
    String id, {
    required double interval,
    required double easeFactor,
    required DateTime nextReviewAt,
    required String status,
  }) async {
    await _supabase
        .from('flashcards')
        .update({
          'interval': interval,
          'ease_factor': easeFactor,
          'next_review_at': nextReviewAt.toIso8601String(),
          'status': status,
        })
        .eq('id', id);
  }
}

final flashcardsRepositoryProvider = Provider<FlashcardsRepository>((ref) {
  return FlashcardsRepository(Supabase.instance.client);
});

final flashcardsStreamProvider = StreamProvider<List<FlashcardModel>>((ref) {
  final repository = ref.watch(flashcardsRepositoryProvider);
  return repository.getDueFlashcards().asStream();
});

final flashcardsDueCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(flashcardsRepositoryProvider);
  return repository.getDueFlashcardsCount();
});
