import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/features/profile/presentation/providers/profile_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/flashcard_model.dart';

class FlashcardsRepository {
  final SupabaseClient _supabase;
  final Ref _ref;

  FlashcardsRepository(this._supabase, this._ref);

  Future<void> addFlashcard({
    required String front,
    required List<String> back,
    required String language,
    String? videoId,
    double? startTime,
    double? endTime,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _supabase.from('flashcards').upsert({
      'user_id': user.id,
      'video_id': videoId,
      'video_timestamp_start': startTime,
      'video_timestamp_end': endTime,
      'type': 'word',
      'front': front,
      'back': back,
      'language': language,
      'status': 'new',
      'step': 0,
      'interval': 0,
      'ease_factor': 2.5,
      'next_review_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,front,language');
  }

  Future<List<FlashcardModel>> getDueFlashcards() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final profile = _ref.watch(userProfileProvider).value;
    final language = profile?['target_language'];

    var builder = _supabase.from('flashcards').select().eq('user_id', user.id);

    if (language != null && language is String && language.isNotEmpty) {
      builder = builder.eq('language', language);
    }

    final response = await builder
        .lte('next_review_at', DateTime.now().toIso8601String())
        .order('next_review_at', ascending: true)
        .limit(20);

    return (response as List).map((e) => FlashcardModel.fromJson(e)).toList();
  }

  Future<int> getDueFlashcardsCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    final profile = _ref.watch(userProfileProvider).value;
    final language = profile?['target_language'];

    var builder = _supabase
        .from('flashcards')
        .count(CountOption.exact)
        .eq('user_id', user.id);

    if (language != null && language is String && language.isNotEmpty) {
      builder = builder.eq('language', language);
    }

    final response = await builder.lte(
      'next_review_at',
      DateTime.now().toIso8601String(),
    );

    return response;
  }

  Future<int> getTotalFlashcardsCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    final profile = _ref.watch(userProfileProvider).value;
    final language = profile?['target_language'];

    var builder = _supabase
        .from('flashcards')
        .count(CountOption.exact)
        .eq('user_id', user.id);

    if (language != null && language is String && language.isNotEmpty) {
      builder = builder.eq('language', language);
    }

    final response = await builder;

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
  return FlashcardsRepository(Supabase.instance.client, ref);
});

final flashcardsStreamProvider = StreamProvider<List<FlashcardModel>>((ref) {
  final repository = ref.watch(flashcardsRepositoryProvider);
  return repository.getDueFlashcards().asStream();
});

final flashcardsDueCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(flashcardsRepositoryProvider);
  return repository.getDueFlashcardsCount();
});

final flashcardsUpdateTriggerProvider =
    NotifierProvider<FlashcardsTriggerNotifier, int>(
      FlashcardsTriggerNotifier.new,
    );

class FlashcardsTriggerNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void trigger() {
    state++;
  }
}
