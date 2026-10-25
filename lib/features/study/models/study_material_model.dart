class StudyMaterialModel {
  final String id;
  final String subjectId;
  final int unitNumber;
  final String unitTitleOm;
  final String topicTitleOm;
  final String summaryContentOm;
  final List<String> keyFormulasOrRules;
  final String pastExamTipsOm;
  final bool isCachedLocally;
  final DateTime updatedAt;

  const StudyMaterialModel({
    required this.id,
    required this.subjectId,
    required this.unitNumber,
    required this.unitTitleOm,
    required this.topicTitleOm,
    required this.summaryContentOm,
    required this.keyFormulasOrRules,
    required this.pastExamTipsOm,
    this.isCachedLocally = true,
    required this.updatedAt,
  });

  factory StudyMaterialModel.fromJson(Map<String, dynamic> json) {
    return StudyMaterialModel(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      unitNumber: json['unitNumber'] as int? ?? 1,
      unitTitleOm: json['unitTitleOm'] as String,
      topicTitleOm: json['topicTitleOm'] as String,
      summaryContentOm: json['summaryContentOm'] as String,
      keyFormulasOrRules: (json['keyFormulasOrRules'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      pastExamTipsOm: json['pastExamTipsOm'] as String? ?? '',
      isCachedLocally: json['isCachedLocally'] as bool? ?? true,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'unitNumber': unitNumber,
      'unitTitleOm': unitTitleOm,
      'topicTitleOm': topicTitleOm,
      'summaryContentOm': summaryContentOm,
      'keyFormulasOrRules': keyFormulasOrRules,
      'pastExamTipsOm': pastExamTipsOm,
      'isCachedLocally': isCachedLocally,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StudyMaterialModel copyWith({
    String? id,
    String? subjectId,
    int? unitNumber,
    String? unitTitleOm,
    String? topicTitleOm,
    String? summaryContentOm,
    List<String>? keyFormulasOrRules,
    String? pastExamTipsOm,
    bool? isCachedLocally,
    DateTime? updatedAt,
  }) {
    return StudyMaterialModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      unitNumber: unitNumber ?? this.unitNumber,
      unitTitleOm: unitTitleOm ?? this.unitTitleOm,
      topicTitleOm: topicTitleOm ?? this.topicTitleOm,
      summaryContentOm: summaryContentOm ?? this.summaryContentOm,
      keyFormulasOrRules: keyFormulasOrRules ?? this.keyFormulasOrRules,
      pastExamTipsOm: pastExamTipsOm ?? this.pastExamTipsOm,
      isCachedLocally: isCachedLocally ?? this.isCachedLocally,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
