class CommentModel {
  final String id;
  final String userId;
  final String videoId;
  final String content;
  final DateTime createdAt;
  final String? userAvatarUrl;
  final String? username;
  final int
  likes; // Future proofing from UI, though schema didn't explicit it yet, we can default 0
  final bool isLiked;

  CommentModel({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.content,
    required this.createdAt,
    this.userAvatarUrl,
    this.username,
    this.likes = 0,
    this.isLiked = false,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['id'],
      userId: json['user_id'],
      videoId: json['video_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      userAvatarUrl: profile?['avatar_url'],
      username: profile?['username'] ?? 'User',
    );
  }
}
