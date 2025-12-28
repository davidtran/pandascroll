import '../network/api_client.dart';

class TranslationService {
  /// Calls the translation API.
  /// Endpoint: POST /translate
  /// Body: { "type": "comment", "id": "..." }
  /// Response: { "data": "Translated text..." }
  Future<String?> translate({required String type, required String id}) async {
    try {
      final response = await ApiClient.post(
        '/translate',
        body: {'type': type, 'id': id},
      );

      return response['data'] as String?;
    } catch (e) {
      // print('Translation API error: $e');
      return null;
    }
  }
}
