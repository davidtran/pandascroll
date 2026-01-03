import 'package:pandascroll/src/features/feed/domain/models/dictionary_model.dart';

class UserDictionaryEntry {
  final String userId;
  final int dictionaryId;
  final DateTime createdAt;
  final String language;
  final DictionaryModel dictionary;

  UserDictionaryEntry({
    required this.userId,
    required this.dictionaryId,
    required this.createdAt,
    required this.language,
    required this.dictionary,
  });

  factory UserDictionaryEntry.fromRow(Map<String, dynamic> row) {
    dynamic dictionaryRaw = row['dictionary'];
    if (dictionaryRaw is List) {
      dictionaryRaw = dictionaryRaw.isNotEmpty
          ? dictionaryRaw.first
          : <String, dynamic>{};
    }
    final dictionaryData = dictionaryRaw as Map<String, dynamic>;
    dynamic contentRaw = dictionaryData['content'];
    if (contentRaw is List) {
      contentRaw = contentRaw.isNotEmpty
          ? contentRaw.first
          : <String, dynamic>{};
    }
    final content = contentRaw as Map<String, dynamic>? ?? {};

    // Merge dictionary fields and content for DictionaryModel
    final mergedDictionary = {
      'id': dictionaryData['id'],
      'word': dictionaryData['word'],
      // content fields might override these if duplicated, or provide missing ones
      ...content,
    };

    return UserDictionaryEntry(
      userId: row['user_id'] as String,
      dictionaryId: row['dictionary_id'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      language: row['language'] as String,
      dictionary: DictionaryModel.fromJson(mergedDictionary),
    );
  }
}
