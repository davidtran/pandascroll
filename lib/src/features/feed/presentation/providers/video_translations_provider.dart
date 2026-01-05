import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandascroll/src/features/profile/presentation/providers/profile_providers.dart';
import '../../../../core/network/api_client.dart';

class TranslationWindow {
  final String title;
  final List<String> sentences;

  TranslationWindow({required this.title, required this.sentences});

  factory TranslationWindow.fromJson(Map<String, dynamic> json) {
    return TranslationWindow(
      title: json['title'] as String? ?? '',
      sentences:
          (json['sentences'] as List?)
              ?.map((e) => (e['text'] as String?) ?? '')
              .toList() ??
          [],
    );
  }
}

class VideoTranslationsNotifier extends AsyncNotifier<List<TranslationWindow>> {
  final String videoId;

  VideoTranslationsNotifier(this.videoId);

  @override
  Future<List<TranslationWindow>> build() async {
    final profile = ref.read(userProfileProvider).value;
    final nativeLanguage = profile?['native_language'] as String;
    try {
      final response = await ApiClient.get(
        '/video-translation?video_id=$videoId&language=$nativeLanguage',
      );

      final List<dynamic> data = response['data'] ?? [];

      return data
          .map((e) => TranslationWindow.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

final videoTranslationsProvider =
    AsyncNotifierProvider.family<
      VideoTranslationsNotifier,
      List<TranslationWindow>,
      String
    >(VideoTranslationsNotifier.new);
