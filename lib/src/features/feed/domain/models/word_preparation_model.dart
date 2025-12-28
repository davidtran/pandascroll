class WordPreparationModel {
  final List<WordItem> words;
  final List<SentenceItem> sentences;

  WordPreparationModel({required this.words, required this.sentences});

  factory WordPreparationModel.fromJson(Map<String, dynamic> json) {
    return WordPreparationModel(
      words:
          (json['words'] as List<dynamic>?)
              ?.map((e) => WordItem.fromJson(e))
              .toList() ??
          [],
      sentences:
          (json['sentences'] as List<dynamic>?)
              ?.map((e) => SentenceItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class WordItem {
  final String word;
  final String type;
  final String pronunciation;
  final String translation;
  final String howToUse;
  final List<ExampleItem> examples;

  WordItem({
    required this.word,
    required this.type,
    required this.pronunciation,
    required this.translation,
    required this.howToUse,
    required this.examples,
  });

  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      word: json['word'] ?? '',
      type: json['type'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      translation: json['translation'] ?? '',
      howToUse: json['how_to_use'] ?? '',
      examples:
          (json['examples'] as List<dynamic>?)
              ?.map((e) => ExampleItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ExampleItem {
  final String text;
  final String translation;
  final String pronunciation;

  ExampleItem({
    required this.text,
    required this.translation,
    required this.pronunciation,
  });

  factory ExampleItem.fromJson(Map<String, dynamic> json) {
    return ExampleItem(
      text: json['text'] ?? '',
      translation: json['translation'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
    );
  }
}

class SentenceItem {
  final String text;
  final String translation;

  SentenceItem({required this.text, required this.translation});

  factory SentenceItem.fromJson(Map<String, dynamic> json) {
    return SentenceItem(
      text: json['text'] ?? '',
      translation: json['translation'] ?? '',
    );
  }
}
