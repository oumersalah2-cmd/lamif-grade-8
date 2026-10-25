class LeaderboardEntry {
  final int rank;
  final String userId;
  final String fullName;
  final String schoolName;
  final String zoneName;
  final double averageScore;
  final int totalExamsTaken;
  final int streakDays;
  final bool isCurrentUser;
  final String? badgeTitleOm;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.fullName,
    required this.schoolName,
    required this.zoneName,
    required this.averageScore,
    required this.totalExamsTaken,
    this.streakDays = 1,
    this.isCurrentUser = false,
    this.badgeTitleOm,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final uid = json['userId'] as String? ?? json['id'] as String? ?? '';
    return LeaderboardEntry(
      rank: json['rank'] as int? ?? 1,
      userId: uid,
      fullName: json['fullName'] as String? ?? 'Barataa Kutaa 8ffaa',
      schoolName: json['schoolName'] as String? ?? 'Mana Barumsaa Sad. 1ffaa',
      zoneName: json['zoneName'] as String? ?? 'Shawaa Bahaa',
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      totalExamsTaken: json['totalExamsTaken'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 1,
      isCurrentUser: currentUserId != null && currentUserId == uid,
      badgeTitleOm: json['badgeTitleOm'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userId': userId,
      'fullName': fullName,
      'schoolName': schoolName,
      'zoneName': zoneName,
      'averageScore': averageScore,
      'totalExamsTaken': totalExamsTaken,
      'streakDays': streakDays,
      'isCurrentUser': isCurrentUser,
      'badgeTitleOm': badgeTitleOm,
    };
  }

  LeaderboardEntry copyWith({
    int? rank,
    String? userId,
    String? fullName,
    String? schoolName,
    String? zoneName,
    double? averageScore,
    int? totalExamsTaken,
    int? streakDays,
    bool? isCurrentUser,
    String? badgeTitleOm,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      schoolName: schoolName ?? this.schoolName,
      zoneName: zoneName ?? this.zoneName,
      averageScore: averageScore ?? this.averageScore,
      totalExamsTaken: totalExamsTaken ?? this.totalExamsTaken,
      streakDays: streakDays ?? this.streakDays,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      badgeTitleOm: badgeTitleOm ?? this.badgeTitleOm,
    );
  }
}
