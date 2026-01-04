import 'dart:math';
import '../network/api_client.dart';

class SpeechScoringService {
  /// Uploads audio file to /transcribe endpoint and returns the transcribed text.
  static Future<String> transcribeAudio(String filePath) async {
    final data = await ApiClient.upload(
      '/transcribe',
      filePath: filePath,
      fieldName: 'file',
      contentType: 'audio/m4a',
    );
    return data['text'] as String? ?? '';
  }

  /// Calculates a similarity score between 0.0 and 1.0.
  static double calculateScore(String transcribed, String original) {
    if (original.isEmpty) return 0.0;

    final normalizedTranscribed = transcribed.toLowerCase().trim();
    final normalizedOriginal = original.toLowerCase().trim();

    if (normalizedTranscribed.isEmpty) return 0.0;

    final distance = _levenshtein(normalizedTranscribed, normalizedOriginal);
    final maxLength = max(
      normalizedTranscribed.length,
      normalizedOriginal.length,
    );

    if (maxLength == 0) return 1.0;

    return 1.0 - (distance / maxLength);
  }

  static int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i++) v0[i] = i;

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < t.length + 1; j++) v0[j] = v1[j];
    }

    return v1[t.length];
  }
}
