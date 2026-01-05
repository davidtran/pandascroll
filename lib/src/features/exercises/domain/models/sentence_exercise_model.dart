class SentenceExerciseModel {
  final String text;
  final String translation;
  final double start;
  final double end;

  SentenceExerciseModel({
    required this.text,
    required this.translation,
    required this.start,
    required this.end,
  });

  factory SentenceExerciseModel.fromJson(Map<String, dynamic> json) {
    return SentenceExerciseModel(
      text: json['text'] as String,
      translation: json['translation'] as String,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
    );
  }
}
