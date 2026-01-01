class VideoModel {
  final String id;
  final DateTime createdAt;
  final String url;
  final String title;
  final String description;
  final String platformType;
  final String language;
  final int durationSeconds;
  final String authorName;
  final String authorUrl;
  final String thumbnailUrl;
  final String externalId;
  final String audioUrl;
  final String text;
  final List<Caption> captions;

  VideoModel({
    required this.id,
    required this.createdAt,
    required this.url,
    required this.title,
    required this.description,
    required this.platformType,
    required this.language,
    required this.durationSeconds,
    required this.authorName,
    required this.authorUrl,
    required this.thumbnailUrl,
    required this.externalId,
    required this.audioUrl,
    required this.text,
    required this.captions,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      url: json['url'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      platformType: json['platform_type'] as String,
      language: json['language'] as String,
      durationSeconds: (json['duration_seconds'] as int?) ?? 0,
      authorName: json['author_name'] as String,
      authorUrl: json['author_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      externalId: (json['external_id'] as String?) ?? "",
      audioUrl: json['audio_url'] as String,
      text: json['text'] as String,
      captions: (json['captions'] as List)
          .map((e) => Caption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Caption {
  final String text;
  final List<Word> words;
  final String translation;

  Caption({required this.text, required this.words, this.translation = ''});

  factory Caption.fromJson(Map<String, dynamic> json) {
    return Caption(
      text: json['text'] as String,
      words: (json['words'] as List)
          .map((e) => Word.fromJson(e as Map<String, dynamic>))
          .toList(),
      translation: json['translation'] as String? ?? '',
    );
  }
}

class Word {
  final String word;
  final double start;
  final double end;

  Word({required this.word, required this.start, required this.end});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'] as String,
      start: _parseNumber(json['start']),
      end: _parseNumber(json['end']),
    );
  }

  static double _parseNumber(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
