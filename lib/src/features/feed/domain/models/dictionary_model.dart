class DictionaryModel {
  final String word;
  final String type;
  final String pronunciation;
  final String translation;
  final String howToUse;
  final List<Example> examples;

  DictionaryModel({
    required this.word,
    required this.type,
    required this.pronunciation,
    required this.translation,
    required this.howToUse,
    required this.examples,
  });

  factory DictionaryModel.fromJson(Map<String, dynamic> json) {
    return DictionaryModel(
      word: json['word'] as String,
      type: json['type'] as String,
      pronunciation: json['pronunciation'] as String,
      translation: json['translation'] as String,
      howToUse: json['how_to_use'] as String,
      examples: (json['examples'] as List)
          .map((e) => Example.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Example {
  final String text;
  final String translation;
  final String pronunciation;

  Example({
    required this.text,
    required this.translation,
    required this.pronunciation,
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      text: json['text'] as String,
      translation: json['translation'] as String,
      pronunciation: json['pronunciation'] as String,
    );
  }
}
