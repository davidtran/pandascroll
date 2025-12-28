import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../onboarding/presentation/providers/onboarding_provider.dart';
import '../domain/models/user_language_profile.dart';
import '../../../core/network/api_client.dart';

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

  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> updateProfileData({
    String? username,
    String? nativeLanguage,
    String? targetLanguage,
    String? avatarUrl,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final updates = {
      'id': userId,

      if (username != null) 'username': username,
      if (nativeLanguage != null) 'native_language': nativeLanguage,
      if (targetLanguage != null) 'target_language': targetLanguage,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };

    await _client.from('profiles').upsert(updates);
  }

  Future<UserLanguageProfile?> getUserLanguageProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      // 1. Get target language
      final profileData = await _client
          .from('profiles')
          .select('target_language')
          .eq('id', userId)
          .maybeSingle();

      if (profileData == null) return null;
      final targetLanguage = profileData['target_language'] as String?;

      if (targetLanguage == null) return null;

      // 2. Get matching language profile
      final response = await _client
          .from('user_language_profiles')
          .select()
          .eq('user_id', userId)
          .eq('language', targetLanguage)
          .maybeSingle();

      if (response == null) return null;
      return UserLanguageProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user language profile: $e');
      return null;
    }
  }

  Future<String?> uploadAvatarBytes(Uint8List bytes, String fileExt) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName; // Path in bucket

      await _client.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      final imageUrl = _client.storage.from('avatars').getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  Future<String?> uploadAvatar(File file) async {
    // Legacy method for mobile-only file objects (deprecated)
    // ... logic remains or redirect to bytes if needed.
    // Keeping it for now but using uploadAvatarBytes is preferred.
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final fileExt = file.path.split('.').last;
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = fileName; // Path in bucket

      await _client.storage
          .from('avatars')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = _client.storage.from('avatars').getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> syncEnergy() async {
    try {
      final response = await ApiClient.post('/sync_energy', body: {});
      // Expected response: { data: { energy: 5, last_energy_updated_at: "..." } }
      if (response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error syncing energy: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> spendEnergy() async {
    try {
      final response = await ApiClient.post('/spend_energy', body: {});
      // Returns updated state: { data: { energy: 4, last_energy_updated_at: "..." } }
      if (response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error spending energy: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> refundEnergy() async {
    try {
      final response = await ApiClient.post('/refund_energy', body: {});
      if (response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error refunding energy: $e');
      return null;
    }
  }
}

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository(Supabase.instance.client);
});
