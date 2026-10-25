import 'package:isar/isar.dart';

part 'question_schema.g.dart';

/// Embedded option within an Isar Question collection
@embedded
class Option {
  late String text;
  late bool isCorrect;

  Option({
    this.text = '',
    this.isCorrect = false,
  });

  Option copyWith({
    String? text,
    bool? isCorrect,
  }) {
    return Option(
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      text: json['text'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }
}

/// Offline-first Isar Question collection for Grade 8 Exam Engine
@collection
class Question {
  Id id = Isar.autoIncrement;

  late String text;
  
  @Index()
  late String subjectId;
  
  late String explanation;

  List<Option> options = [];

  Question({
    this.id = Isar.autoIncrement,
    this.text = '',
    this.subjectId = '',
    this.explanation = '',
    List<Option>? options,
  }) : options = options ?? [];

  /// Factory helper to build from basic question parameters
  factory Question.create({
    Id id = Isar.autoIncrement,
    required String text,
    required String subjectId,
    required String explanation,
    required List<Option> options,
  }) {
    return Question(
      id: id,
      text: text,
      subjectId: subjectId,
      explanation: explanation,
      options: options,
    );
  }

  Question copyWith({
    Id? id,
    String? text,
    String? subjectId,
    String? explanation,
    List<Option>? options,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      subjectId: subjectId ?? this.subjectId,
      explanation: explanation ?? this.explanation,
      options: options ?? List.from(this.options),
    );
  }

  int get correctOptionIndex {
    return options.indexWhere((opt) => opt.isCorrect);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'subjectId': subjectId,
      'explanation': explanation,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int? ?? Isar.autoIncrement,
      text: json['text'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => Option.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
