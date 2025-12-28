class ExerciseModel {
  final String id;
  final String type;
  final dynamic data;

  ExerciseModel({required this.id, required this.type, required this.data});

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      type: json['exercise_type'] as String,
      data: json['data'],
    );
  }
}

class WordQuizData {
  final String word;
  final List<String> options;
  final String correctMeaning;

  WordQuizData({
    required this.word,
    required this.options,
    required this.correctMeaning,
  });

  factory WordQuizData.fromJson(Map<String, dynamic> json) {
    return WordQuizData(
      word: json['word'] as String,
      options: List<String>.from(json['options']),
      correctMeaning: json['correct_meaning'] as String,
    );
  }
}

class ScrambleWord {
  final int id;
  final String text;

  ScrambleWord({required this.id, required this.text});

  factory ScrambleWord.fromJson(Map<String, dynamic> json) {
    return ScrambleWord(id: json['id'] as int, text: json['text'] as String);
  }
}

class ScrambleData {
  final String title;
  final double audioStart;
  final double audioEnd;
  final String sentenceText;
  final List<String> words;

  ScrambleData({
    required this.title,
    required this.audioStart,
    required this.audioEnd,
    required this.sentenceText,
    required this.words,
  });

  factory ScrambleData.fromJson(Map<String, dynamic> json) {
    return ScrambleData(
      title: json['title'] as String,
      audioStart: (json['audio_start'] as num).toDouble(),
      audioEnd: (json['audio_end'] as num).toDouble(),
      sentenceText: json['sentence_text'] as String,
      words: List<String>.from(json['words']),
    );
  }
}

class VideoUnderstandingData {
  final String question;
  final List<String> options;
  final String correctAnswer;

  VideoUnderstandingData({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory VideoUnderstandingData.fromJson(Map<String, dynamic> json) {
    return VideoUnderstandingData(
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      correctAnswer: json['correct_answer'] as String,
    );
  }
}

class ClozeData {
  final String sentenceDisplay;
  final List<String> options;
  final double audioStart;
  final double audioEnd;
  final String correctAnswer;

  ClozeData({
    required this.sentenceDisplay,
    required this.options,
    required this.audioStart,
    required this.audioEnd,
    required this.correctAnswer,
  });

  factory ClozeData.fromJson(Map<String, dynamic> json) {
    return ClozeData(
      sentenceDisplay: json['sentence_display'] as String,
      options: List<String>.from(json['options']),
      audioStart: (json['audio_start'] as num).toDouble(),
      audioEnd: (json['audio_end'] as num).toDouble(),
      correctAnswer: json['correct_answer'] as String,
    );
  }
}

class ParrotData {
  final String title;
  final double audioStart;
  final double audioEnd;
  final String sentenceText;

  ParrotData({
    required this.title,
    required this.audioStart,
    required this.audioEnd,
    required this.sentenceText,
  });

  factory ParrotData.fromJson(Map<String, dynamic> json) {
    return ParrotData(
      title: json['title'] as String,
      audioStart: (json['audio_start'] as num).toDouble(),
      audioEnd: (json['audio_end'] as num).toDouble(),
      sentenceText: json['sentence_text'] as String,
    );
  }
}
