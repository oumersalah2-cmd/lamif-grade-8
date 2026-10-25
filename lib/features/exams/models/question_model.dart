class QuestionModel {
  final String id;
  final String subjectId;
  final String topicOm;
  final String questionTextOm;
  final String? questionTextEn;
  final List<String> options;
  final int correctOptionIndex;
  final String explanationOm;
  final String? examYear;
  final String difficulty;

  const QuestionModel({
    required this.id,
    required this.subjectId,
    required this.topicOm,
    required this.questionTextOm,
    this.questionTextEn,
    required this.options,
    required this.correctOptionIndex,
    required this.explanationOm,
    this.examYear = "2016 E.C.",
    this.difficulty = "Medium",
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      topicOm: json['topicOm'] as String,
      questionTextOm: json['questionTextOm'] as String,
      questionTextEn: json['questionTextEn'] as String?,
      options: (json['options'] as List<dynamic>).map((e) => e.toString()).toList(),
      correctOptionIndex: json['correctOptionIndex'] as int,
      explanationOm: json['explanationOm'] as String,
      examYear: json['examYear'] as String? ?? "2016 E.C.",
      difficulty: json['difficulty'] as String? ?? "Medium",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'topicOm': topicOm,
      'questionTextOm': questionTextOm,
      'questionTextEn': questionTextEn,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'explanationOm': explanationOm,
      'examYear': examYear,
      'difficulty': difficulty,
    };
  }
}
