class SubjectModel {
  final String id;
  final String nameOm;
  final String nameEn;
  final String descriptionOm;
  final String iconName;
  final String accentColorHex;
  final int totalUnits;
  final int totalQuestionsCount;
  final bool isDownloadedForOffline;

  const SubjectModel({
    required this.id,
    required this.nameOm,
    required this.nameEn,
    required this.descriptionOm,
    required this.iconName,
    required this.accentColorHex,
    this.totalUnits = 5,
    this.totalQuestionsCount = 50,
    this.isDownloadedForOffline = true,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      nameOm: json['nameOm'] as String,
      nameEn: json['nameEn'] as String,
      descriptionOm: json['descriptionOm'] as String,
      iconName: json['iconName'] as String? ?? 'book',
      accentColorHex: json['accentColorHex'] as String? ?? '#16A34A',
      totalUnits: json['totalUnits'] as int? ?? 5,
      totalQuestionsCount: json['totalQuestionsCount'] as int? ?? 50,
      isDownloadedForOffline: json['isDownloadedForOffline'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameOm': nameOm,
      'nameEn': nameEn,
      'descriptionOm': descriptionOm,
      'iconName': iconName,
      'accentColorHex': accentColorHex,
      'totalUnits': totalUnits,
      'totalQuestionsCount': totalQuestionsCount,
      'isDownloadedForOffline': isDownloadedForOffline,
    };
  }

  SubjectModel copyWith({
    String? id,
    String? nameOm,
    String? nameEn,
    String? descriptionOm,
    String? iconName,
    String? accentColorHex,
    int? totalUnits,
    int? totalQuestionsCount,
    bool? isDownloadedForOffline,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      nameOm: nameOm ?? this.nameOm,
      nameEn: nameEn ?? this.nameEn,
      descriptionOm: descriptionOm ?? this.descriptionOm,
      iconName: iconName ?? this.iconName,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      totalUnits: totalUnits ?? this.totalUnits,
      totalQuestionsCount: totalQuestionsCount ?? this.totalQuestionsCount,
      isDownloadedForOffline: isDownloadedForOffline ?? this.isDownloadedForOffline,
    );
  }
}
