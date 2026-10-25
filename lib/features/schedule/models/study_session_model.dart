/// Represents days of the week in Afaan Oromoo with standard ordering
enum DayOfWeekOm {
  wiixata('WIIXATA', 'Wix', 'Wiixata', 'Monday'),
  kibxata('KIBXATA', 'Kib', 'Kibxata', 'Tuesday'),
  roobii('ROOBII', 'Roob', 'Roobii', 'Wednesday'),
  kamisa('KAMISA', 'Kam', 'Kamisa', 'Thursday'),
  jimaata('JIMAATA', 'Jim', 'Jimaata', 'Friday'),
  sanbata('SANBATA', 'San', 'Sanbata', 'Saturday'),
  dilbata('DILBATA', 'Dil', 'Dilbata', 'Sunday');

  final String id;
  final String shortNameOm;
  final String nameOm;
  final String nameEn;

  const DayOfWeekOm(this.id, this.shortNameOm, this.nameOm, this.nameEn);

  static DayOfWeekOm fromId(String id) {
    return DayOfWeekOm.values.firstWhere(
      (e) => e.id.toUpperCase() == id.toUpperCase(),
      orElse: () => DayOfWeekOm.wiixata,
    );
  }
}

/// Represents an offline-persisted study session for Grade 8 students
class StudySessionModel {
  final String id;
  final String subjectId;
  final String subjectNameOm;
  final DayOfWeekOm dayOfWeek;
  final String startTime; // e.g. "08:30", "16:00"
  final int durationMinutes; // e.g. 45, 60
  final String topicFocusOm;
  final bool isCompleted;
  final String? notes;

  const StudySessionModel({
    required this.id,
    required this.subjectId,
    required this.subjectNameOm,
    required this.dayOfWeek,
    required this.startTime,
    required this.durationMinutes,
    required this.topicFocusOm,
    this.isCompleted = false,
    this.notes,
  });

  StudySessionModel copyWith({
    String? id,
    String? subjectId,
    String? subjectNameOm,
    DayOfWeekOm? dayOfWeek,
    String? startTime,
    int? durationMinutes,
    String? topicFocusOm,
    bool? isCompleted,
    String? notes,
  }) {
    return StudySessionModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      subjectNameOm: subjectNameOm ?? this.subjectNameOm,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      topicFocusOm: topicFocusOm ?? this.topicFocusOm,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'subjectNameOm': subjectNameOm,
      'dayOfWeek': dayOfWeek.id,
      'startTime': startTime,
      'durationMinutes': durationMinutes,
      'topicFocusOm': topicFocusOm,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      subjectNameOm: json['subjectNameOm'] as String,
      dayOfWeek: DayOfWeekOm.fromId(json['dayOfWeek'] as String),
      startTime: json['startTime'] as String,
      durationMinutes: json['durationMinutes'] as int,
      topicFocusOm: json['topicFocusOm'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySessionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => id.hashCode ^ isCompleted.hashCode;
}
