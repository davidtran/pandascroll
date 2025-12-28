import 'dart:convert';

class FlashcardModel {
  final String id;
  final String userId;
  final String? videoId;
  final double? videoTimestampStart;
  final double? videoTimestampEnd;
  final String type;
  final String front;
  final List<String> back;
  final String status;
  final double step;
  final double interval;
  final double easeFactor;
  final DateTime nextReviewAt;
  final DateTime createdAt;

  FlashcardModel({
    required this.id,
    required this.userId,
    this.videoId,
    this.videoTimestampStart,
    this.videoTimestampEnd,
    required this.type,
    required this.front,
    required this.back,
    required this.status,
    required this.step,
    required this.interval,
    required this.easeFactor,
    required this.nextReviewAt,
    required this.createdAt,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    List<String> parseBack(dynamic backData) {
      if (backData is List) {
        return backData.map((e) => e.toString()).toList();
      } else if (backData is String) {
        try {
          final decoded = jsonDecode(backData);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          // If not JSON list, treat as single string in list
          return [backData];
        }
        return [backData];
      }
      return [];
    }

    return FlashcardModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      videoId: json['video_id'] as String?,
      videoTimestampStart: (json['video_timestamp_start'] as num?)?.toDouble(),
      videoTimestampEnd: (json['video_timestamp_end'] as num?)?.toDouble(),
      type: json['type'] as String? ?? 'word',
      front: json['front'] as String? ?? '',
      back: parseBack(json['back']),
      status: json['status'] as String? ?? 'new',
      step: (json['step'] as num?)?.toDouble() ?? 0,
      interval: (json['interval'] as num?)?.toDouble() ?? 0,
      easeFactor: (json['ease_factor'] as num?)?.toDouble() ?? 2.5,
      nextReviewAt: DateTime.parse(json['next_review_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'video_id': videoId,
      'video_timestamp_start': videoTimestampStart,
      'video_timestamp_end': videoTimestampEnd,
      'type': type,
      'front': front,
      'back': jsonEncode(back), // Verify if DB expects JSON string or array
      'status': status,
      'step': step,
      'interval': interval,
      'ease_factor': easeFactor,
      'next_review_at': nextReviewAt.toIso8601String(),
    };
  }
}
