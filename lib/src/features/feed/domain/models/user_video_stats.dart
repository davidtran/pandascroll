class UserVideoStats {
  final String userId;
  final String videoId;
  final double? viewDuration;
  final bool? liked;
  final DateTime? lastViewedAt;
  final double? exerciseScores;
  final double? totalExercises;

  UserVideoStats({
    required this.userId,
    required this.videoId,
    this.viewDuration,
    this.liked,
    this.lastViewedAt,
    this.exerciseScores,
    this.totalExercises,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'video_id': videoId,
      if (viewDuration != null) 'view_duration': viewDuration,
      if (liked != null) 'liked': liked,
      if (lastViewedAt != null)
        'last_viewed_at': lastViewedAt!.toIso8601String(),
      if (exerciseScores != null) 'exercise_scores': exerciseScores,
      if (totalExercises != null) 'total_exercises': totalExercises,
    };
  }

  factory UserVideoStats.fromJson(Map<String, dynamic> json) {
    return UserVideoStats(
      userId: json['user_id'],
      videoId: json['video_id'],
      viewDuration: json['view_duration']?.toDouble(),
      liked: json['liked'],
      lastViewedAt: json['last_viewed_at'] != null
          ? DateTime.parse(json['last_viewed_at'])
          : null,
      exerciseScores: json['exercise_scores']?.toDouble(),
      totalExercises: json['total_exercises']?.toDouble(),
    );
  }
}
