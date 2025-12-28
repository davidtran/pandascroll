import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'language_detection_service.dart';
import 'translation_service.dart';
import 'content_moderation_service.dart';

final languageDetectionServiceProvider =
    Provider.autoDispose<LanguageDetectionService>((ref) {
      final service = LanguageDetectionService();
      ref.onDispose(() => service.dispose());
      return service;
    });

final contentModerationServiceProvider = Provider<ContentModerationService>((
  ref,
) {
  return ContentModerationService();
});
final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});
