import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/features/profile/presentation/providers/profile_providers.dart';
import '../../../../core/network/api_client.dart';

class VideoTranslationsNotifier extends AsyncNotifier<List<String>> {
  final String videoId;

  VideoTranslationsNotifier(this.videoId);

  @override
  Future<List<String>> build() async {
    final profile = ref.read(userProfileProvider).value;
    final nativeLanguage = profile?['native_language'] as String;
    try {
      final response = await ApiClient.get(
        '/video-translation?video_id=$videoId&language=$nativeLanguage',
      );

      final List<dynamic> data = response['data'] ?? [];

      // Assuming the data is a list of strings
      return data.map((e) => e.toString()).toList();
    } catch (e) {
      rethrow;
    }
  }
}

final videoTranslationsProvider =
    AsyncNotifierProvider.family<
      VideoTranslationsNotifier,
      List<String>,
      String
    >(VideoTranslationsNotifier.new);
