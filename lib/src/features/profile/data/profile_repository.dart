import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../onboarding/presentation/providers/onboarding_provider.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<void> updateProfile(String userId, OnboardingState data) async {
    final updates = {
      'id': userId,
      if (data.nativeLanguage != null) 'native_language': data.nativeLanguage,
      if (data.targetLanguage != null) 'target_language': data.targetLanguage,
      if (data.categories.isNotEmpty) 'categories': data.categories,
      if (data.level != null) 'level': data.level,
    };

    if (updates.length > 2) {
      // id and updated_at are always there
      await _client.from('profiles').upsert(updates);
    }
  }
}

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository(Supabase.instance.client);
});
