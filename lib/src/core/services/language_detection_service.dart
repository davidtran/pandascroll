import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;

class LanguageDetectionService {
  bool _isInitialized = false;

  /// Initializes the language detection bundle.
  /// Should be called once at app startup or before first use.
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await langdetect.initLangDetect();
      _isInitialized = true;
    } catch (e) {
      // Handle initialization error (e.g., assets not found)
      // print("Error initializing langdetect: $e");
    }
  }

  /// Returns the language code (e.g., 'en', 'es') for the given text.
  /// Returns 'und' (undetermined) if the language cannot be identified.
  Future<String> identifyLanguage(String text) async {
    if (!_isInitialized) {
      await init();
    }

    if (text.isEmpty) return 'und';

    try {
      final String languageCode = langdetect.detect(text).substring(0, 2);
      return languageCode;
    } catch (e) {
      // detect() throws if it can't detect, often returns 'unknown' or throws exception
      return 'und';
    }
  }

  // No explicit dispose needed for flutter_langdetect
  void dispose() {}
}
