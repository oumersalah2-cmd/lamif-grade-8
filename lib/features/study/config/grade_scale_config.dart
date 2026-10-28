/// Configuration for the Ethiopian / Oromia Grade 8 (Kutaa 8) Grading System.
/// Centralizes all subject definitions, maximum marks, pass/fail thresholds, and achievement levels.
///
/// TODO: Official Oromia Grade 8 grading scale placeholder.
/// Replace the threshold percentages and subject maximum marks below with the official table
/// from the Oromia Education Bureau (Biiroo Barnoota Oromiyaa) once officially gazetted.

class GradeSubjectConfig {
  final String id;
  final String nameOm;
  final String nameEn;
  final double defaultMaxMark;
  final bool isCoreSubject;

  const GradeSubjectConfig({
    required this.id,
    required this.nameOm,
    required this.nameEn,
    this.defaultMaxMark = 100.0,
    this.isCoreSubject = true,
  });
}

class GradeAchievementTier {
  final String letterGrade;
  final String titleOm;
  final String titleEn;
  final double minPercentage; // e.g. 85.0
  final int colorHex;

  const GradeAchievementTier({
    required this.letterGrade,
    required this.titleOm,
    required this.titleEn,
    required this.minPercentage,
    required this.colorHex,
  });
}

class GradeScaleConfig {
  // TODO: Verify if passing mark is 50% across all 21 zones of Oromia
  static const double defaultPassingPercentage = 50.0;

  /// Standard Grade 8 Ministry Exam Subjects in Oromia
  static const List<GradeSubjectConfig> standardSubjects = [
    GradeSubjectConfig(
      id: 'afaan_oromoo',
      nameOm: 'Afaan Oromoo',
      nameEn: 'Afaan Oromoo',
      defaultMaxMark: 100.0,
    ),
    GradeSubjectConfig(
      id: 'herrega',
      nameOm: 'Herrega',
      nameEn: 'Mathematics',
      defaultMaxMark: 100.0,
    ),
    GradeSubjectConfig(
      id: 'saayinsii_waliigalaa',
      nameOm: 'Saayinsii Waliigalaa',
      nameEn: 'General Science',
      defaultMaxMark: 100.0,
    ),
    GradeSubjectConfig(
      id: 'saayinsii_hawaasaa',
      nameOm: 'Saayinsii Hawaasaa',
      nameEn: 'Social Studies',
      defaultMaxMark: 100.0,
    ),
    GradeSubjectConfig(
      id: 'lammummaa',
      nameOm: 'Barnoota Lammummaa',
      nameEn: 'Citizenship',
      defaultMaxMark: 100.0,
    ),
    GradeSubjectConfig(
      id: 'english',
      nameOm: 'Afaan Ingilizii',
      nameEn: 'English Language',
      defaultMaxMark: 100.0,
    ),
    GradeSubjectConfig(
      id: 'ogummaa_ict',
      nameOm: 'Ogummaa fi Teeknoolojii (ICT)',
      nameEn: 'Career & ICT',
      defaultMaxMark: 100.0,
    ),
  ];

  /// Standard Ministry Performance Bands
  // TODO: Replace with regional letter grades / GPA scale if standardized by regional bureau
  static const List<GradeAchievementTier> achievementTiers = [
    GradeAchievementTier(
      letterGrade: 'A',
      titleOm: "Baay'ee Gaarii (Olaanaa)",
      titleEn: 'Outstanding / Distinction',
      minPercentage: 85.0,
      colorHex: 0xFF15803D, // Green
    ),
    GradeAchievementTier(
      letterGrade: 'B',
      titleOm: 'Gaarii',
      titleEn: 'Very Good',
      minPercentage: 75.0,
      colorHex: 0xFF2563EB, // Blue
    ),
    GradeAchievementTier(
      letterGrade: 'C',
      titleOm: 'Giddu-galeessa',
      titleEn: 'Satisfactory / Good',
      minPercentage: 60.0,
      colorHex: 0xFFD97706, // Amber
    ),
    GradeAchievementTier(
      letterGrade: 'D',
      titleOm: 'Darbe (Gadi-aanaa)',
      titleEn: 'Pass / Fair',
      minPercentage: 50.0,
      colorHex: 0xFFEA580C, // Orange
    ),
    GradeAchievementTier(
      letterGrade: 'F',
      titleOm: 'Kufe (Gadi-aanaa)',
      titleEn: 'Unsatisfactory / Fail',
      minPercentage: 0.0,
      colorHex: 0xFFDC2626, // Red
    ),
  ];

  /// Resolves the tier for a given percentage
  static GradeAchievementTier resolveTier(double percentage) {
    for (final tier in achievementTiers) {
      if (percentage >= tier.minPercentage) {
        return tier;
      }
    }
    return achievementTiers.last;
  }
}
