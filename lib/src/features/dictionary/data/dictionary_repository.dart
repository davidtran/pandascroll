import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/user_dictionary_model.dart';

class DictionaryRepository {
  final SupabaseClient _client;

  DictionaryRepository(this._client);

  Future<List<UserDictionaryEntry>> getUserDictionary() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('user_dictionary')
          .select('*, dictionary:dictionary_id(*)')
          .eq('user_id', userId)
          .filter('deleted_at', 'is', 'null')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data
          .map(
            (row) => UserDictionaryEntry.fromRow(row as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      // print('Error fetching dictionary: $e');
      rethrow;
    }
  }

  Future<void> removeFromDictionary(int dictionaryId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('user_dictionary')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .match({'user_id': userId, 'dictionary_id': dictionaryId});
  }
}

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  return DictionaryRepository(Supabase.instance.client);
});

final userDictionaryProvider = FutureProvider<List<UserDictionaryEntry>>((
  ref,
) async {
  final repository = ref.watch(dictionaryRepositoryProvider);
  return repository.getUserDictionary();
});
