class UserLanguageProfile {
  final String id;
  final String? language;
  final double xp;
  final double remainXp;
  final int level;

  UserLanguageProfile({
    required this.id,
    this.language,
    required this.xp,
    required this.remainXp,
    required this.level,
  });

  factory UserLanguageProfile.fromJson(Map<String, dynamic> json) {
    return UserLanguageProfile(
      id: json['id'] as String,
      language: json['language'] as String?,
      xp: (json['xp'] as num?)?.toDouble() ?? 0.0,
      remainXp: (json['remain_xp'] as num?)?.toDouble() ?? 0.0,
      level: (json['level'] as num?)?.toInt() ?? 1,
    );
  }
}
