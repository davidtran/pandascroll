import '../network/api_client.dart';

class ContentModerationService {
  Future<bool> moderate(String text) async {
    if (text.isEmpty) return true;

    try {
      final response = await ApiClient.post('/moderate', body: {'text': text});

      // Parse response structure: { data: { flagged: true/false } }
      final data = response['data'];
      if (data is Map && data['flagged'] == true) {
        return false; // Content is flagged as inappropriate
      }

      return true; // Content is safe
    } catch (e) {
      return false;
    }
  }
}
