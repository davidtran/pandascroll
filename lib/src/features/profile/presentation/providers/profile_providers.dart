import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/profile_repository.dart';
import '../../../feed/presentation/providers/stats_provider.dart';
import '../../domain/models/user_language_profile.dart';

class UserLanguageProfileNotifier extends AsyncNotifier<UserLanguageProfile?> {
  @override
  Future<UserLanguageProfile?> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    return repo.getUserLanguageProfile();
  }

  Future<void> addXp({
    required String event,
    double? value,
    String? videoId,
  }) async {
    final statsRepo = ref.read(statsRepositoryProvider);
    final result = await statsRepo.addXp(
      event: event,
      value: value,
      videoId: videoId,
    );

    if (result != null && state.hasValue && state.value != null) {
      final currentProfile = state.value!;

      final data = result['data'] is Map ? result['data'] : result;

      // Update local state with returned values
      final newXp = (data['xp'] as num?)?.toDouble() ?? currentProfile.xp;
      final newLevel = (data['level'] as num?)?.toInt() ?? currentProfile.level;
      final newRemainXp =
          (data['remain_xp'] as num?)?.toDouble() ?? currentProfile.remainXp;

      state = AsyncData(
        UserLanguageProfile(
          id: currentProfile.id,
          language: currentProfile.language,
          xp: newXp,
          level: newLevel,
          remainXp: newRemainXp,
        ),
      );
    }
  }
}

final userLanguageProfileProvider =
    AsyncNotifierProvider<UserLanguageProfileNotifier, UserLanguageProfile?>(
      UserLanguageProfileNotifier.new,
    );

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getUserProfile();
});
