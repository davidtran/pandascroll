class LanguageUtils {
  static String getLanguageName(String? code) {
    switch (code?.toLowerCase()) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'zh':
        return 'Chinese';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'it':
        return 'Italian';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      case 'pt':
        return 'Portuguese';
      case 'ru':
        return 'Russian';
      case 'vi':
        return 'Vietnamese';
      case 'hi':
        return 'Hindi';
      case 'ar':
        return 'Arabic';
      default:
        return 'Language';
    }
  }
}
