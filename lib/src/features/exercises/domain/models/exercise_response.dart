import '../../../feed/domain/models/dictionary_model.dart';

class ExerciseResponse {
  final List<DictionaryModel> words;
  final Map<String, List<String>> wordOptions;

  ExerciseResponse({required this.words, required this.wordOptions});

  factory ExerciseResponse.fromJson(Map<String, dynamic> json) {
    // Handle optional 'data' wrapper if present
    final data = json.containsKey('data')
        ? json['data'] as Map<String, dynamic>
        : json;

    return ExerciseResponse(
      words: (data['words'] as List)
          .map((e) => DictionaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      wordOptions: Map<String, dynamic>.from(data['word_options'] as Map).map(
        (key, value) =>
            MapEntry(key, (value as List).map((e) => e.toString()).toList()),
      ),
    );
  }
}
