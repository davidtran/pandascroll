import '../../features/onboarding/domain/models/language_option.dart';

class LanguageConstants {
  static const List<LanguageOption> targetLanguages = [
    LanguageOption(
      name: 'English',
      subtitle: 'Hello',
      flagUrl: 'english.png',
      code: 'en',
      available: true,
    ),
    LanguageOption(
      name: 'Chinese',
      subtitle: '你好',
      flagUrl: 'chinese.png',
      code: 'zh',
      available: true,
    ),

    LanguageOption(
      name: 'Japanese',
      subtitle: 'こんにちは',
      flagUrl: 'japanese.png',
      code: 'ja',
      available: false,
    ),
    LanguageOption(
      name: 'Korean',
      subtitle: '안녕하세요',
      flagUrl: 'korean.png',
      code: 'ko',
      available: false,
    ),
    LanguageOption(
      name: 'Spanish',
      subtitle: 'Hola',
      flagUrl: 'spanish.png',
      code: 'es',
      available: false,
    ),
  ];

  static const List<LanguageOption> nativeLanguages = [
    LanguageOption(
      code: 'en',
      name: 'English',
      subtitle: 'English',
      flagUrl: 'english.png',
    ),
    LanguageOption(
      code: 'es',
      name: 'Spanish',
      subtitle: 'Español',
      flagUrl: 'spanish.png',
    ),
    LanguageOption(
      code: 'fr',
      name: 'French',
      subtitle: 'Français',
      flagUrl: 'french.png',
    ),
    LanguageOption(
      code: 'de',
      name: 'German',
      subtitle: 'Deutsch',
      flagUrl: 'german.png',
    ),
    LanguageOption(
      code: 'ja',
      name: 'Japanese',
      subtitle: '日本語',
      flagUrl: 'japanese.png',
    ),
    LanguageOption(
      code: 'zh',
      name: 'Chinese',
      subtitle: '中文',
      flagUrl: 'chinese.png',
    ),
    LanguageOption(
      code: 'ko',
      name: 'Korean',
      subtitle: '한국어',
      flagUrl: 'korean.png',
    ),
    LanguageOption(
      code: 'pt',
      name: 'Portuguese',
      subtitle: 'Português',
      flagUrl: 'portuguese.png',
    ),
    LanguageOption(
      code: 'vi',
      name: 'Vietnamese',
      subtitle: 'Tiếng Việt',
      flagUrl: 'vietnamese.png',
      keepCase: true,
    ),
    LanguageOption(
      code: 'it',
      name: 'Italian',
      subtitle: 'Italiano',
      flagUrl: 'italian.png',
    ),
    LanguageOption(
      code: 'ru',
      name: 'Russian',
      subtitle: 'Русский',
      flagUrl: 'russian.png',
    ),
    LanguageOption(
      code: 'id',
      name: 'Indonesian',
      subtitle: 'Bahasa Indonesia',
      flagUrl: 'indonesia.png',
    ),
    LanguageOption(
      code: 'th',
      name: 'Thai',
      subtitle: 'ไทย',
      flagUrl: 'thai.png',
    ),
  ];
}
