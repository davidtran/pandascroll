import '../../../feed/domain/models/dictionary_model.dart';

class ExerciseSentence {
  final String text;
  final double start;
  final double end;

  ExerciseSentence({
    required this.text,
    required this.start,
    required this.end,
  });

  factory ExerciseSentence.fromJson(Map<String, dynamic> json) {
    return ExerciseSentence(
      text: json['text'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
    );
  }
}

class ExerciseDictionaryModel extends DictionaryModel {
  final ExerciseSentence sentence;

  ExerciseDictionaryModel({
    required super.id,
    required super.word,
    required super.type,
    required super.pronunciation,
    required super.translation,
    required super.howToUse,
    required super.examples,
    required this.sentence,
  });

  factory ExerciseDictionaryModel.fromJson(Map<String, dynamic> json) {
    return ExerciseDictionaryModel(
      id: json['id'].toString(),
      word: json['word'] as String,
      type: json['type'] as String,
      pronunciation: json['pronunciation'] as String,
      translation: json['translation'] as String,
      howToUse: json['how_to_use'] as String,
      examples: (json['examples'] as List)
          .map((e) => Example.fromJson(e as Map<String, dynamic>))
          .toList(),
      sentence: ExerciseSentence.fromJson(
        json['sentence'] as Map<String, dynamic>,
      ),
    );
  }
}
