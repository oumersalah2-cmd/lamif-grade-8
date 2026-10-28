import 'package:flutter_test/flutter_test.dart';
import 'package:lamif_grade_8/features/study/config/grade_scale_config.dart';
import 'package:lamif_grade_8/features/study/models/grade_calculation_model.dart';
import 'package:lamif_grade_8/features/study/services/grade_calculator_service.dart';

void main() {
  group('GradeCalculatorService - calculateSummary', () {
    test('handles empty subject list gracefully', () {
      final summary = GradeCalculatorService.calculateSummary(entries: []);
      expect(summary.totalObtained, 0.0);
      expect(summary.totalMax, 0.0);
      expect(summary.averagePercentage, 0.0);
      expect(summary.isPassed, false);
      expect(summary.enteredSubjectsCount, 0);
      expect(summary.totalSubjectsCount, 0);
    });

    test('ignores subjects with zero max mark to prevent division by zero', () {
      final entries = [
        const SubjectScoreEntry(
          subjectId: 's1',
          subjectNameOm: 'Afaan Oromoo',
          subjectNameEn: 'Afaan Oromoo',
          scoreObtained: 50.0,
          maxMark: 0.0,
        ),
      ];
      final summary = GradeCalculatorService.calculateSummary(entries: entries);
      expect(summary.totalMax, 0.0);
      expect(summary.averagePercentage, 0.0);
      expect(summary.enteredSubjectsCount, 0);
    });

    test('calculates correct total and average percentage for standard 100-mark subjects', () {
      final entries = [
        const SubjectScoreEntry(
          subjectId: 'herrega',
          subjectNameOm: 'Herrega',
          subjectNameEn: 'Maths',
          scoreObtained: 80.0,
          maxMark: 100.0,
        ),
        const SubjectScoreEntry(
          subjectId: 'english',
          subjectNameOm: 'English',
          subjectNameEn: 'English',
          scoreObtained: 60.0,
          maxMark: 100.0,
        ),
      ];

      final summary = GradeCalculatorService.calculateSummary(entries: entries);
      expect(summary.totalObtained, 140.0);
      expect(summary.totalMax, 200.0);
      expect(summary.averagePercentage, 70.0);
      expect(summary.isPassed, true);
      expect(summary.tier.letterGrade, 'C');
      expect(summary.enteredSubjectsCount, 2);
    });

    test('handles custom maximum marks (e.g. 50-mark tests and 100-mark tests)', () {
      final entries = [
        const SubjectScoreEntry(
          subjectId: 'sub1',
          subjectNameOm: 'Sub 1',
          subjectNameEn: 'Sub 1',
          scoreObtained: 40.0,
          maxMark: 50.0, // 80%
        ),
        const SubjectScoreEntry(
          subjectId: 'sub2',
          subjectNameOm: 'Sub 2',
          subjectNameEn: 'Sub 2',
          scoreObtained: 60.0,
          maxMark: 100.0, // 60%
        ),
      ];

      final summary = GradeCalculatorService.calculateSummary(entries: entries);
      expect(summary.totalObtained, 100.0);
      expect(summary.totalMax, 150.0);
      // 100 / 150 = 66.7%
      expect(summary.averagePercentage, 66.7);
      expect(summary.isPassed, true);
    });

    test('accurately assigns pass or fail based on 50% threshold', () {
      final failEntries = [
        const SubjectScoreEntry(
          subjectId: 'herrega',
          subjectNameOm: 'Herrega',
          subjectNameEn: 'Maths',
          scoreObtained: 45.0,
          maxMark: 100.0,
        ),
      ];
      final failSummary = GradeCalculatorService.calculateSummary(entries: failEntries);
      expect(failSummary.isPassed, false);
      expect(failSummary.tier.letterGrade, 'F');

      final passEntries = [
        const SubjectScoreEntry(
          subjectId: 'herrega',
          subjectNameOm: 'Herrega',
          subjectNameEn: 'Maths',
          scoreObtained: 50.0,
          maxMark: 100.0,
        ),
      ];
      final passSummary = GradeCalculatorService.calculateSummary(entries: passEntries);
      expect(passSummary.isPassed, true);
      expect(passSummary.tier.letterGrade, 'D');
    });
  });

  group('GradeCalculatorService - planTarget', () {
    test('handles empty subject list in target planner', () {
      final plan = GradeCalculatorService.planTarget(
        entries: [],
        targetPercentage: 75.0,
      );
      expect(plan.isAchievable, false);
      expect(plan.remainingSubjectsCount, 0);
    });

    test('calculates needed average on remaining subjects (achievable case)', () {
      // 4 subjects total, each 100 max marks.
      // Target = 75% -> 300 total points needed out of 400.
      // Student has entered 2 subjects: 70 and 70 (140 points).
      // Points needed = 300 - 140 = 160 points.
      // 2 remaining subjects -> 160 / 200 = 80.0% required.
      final entries = [
        const SubjectScoreEntry(
          subjectId: 's1',
          subjectNameOm: 'Herrega',
          subjectNameEn: 'Math',
          scoreObtained: 70.0,
          maxMark: 100.0,
        ),
        const SubjectScoreEntry(
          subjectId: 's2',
          subjectNameOm: 'English',
          subjectNameEn: 'English',
          scoreObtained: 70.0,
          maxMark: 100.0,
        ),
        const SubjectScoreEntry(
          subjectId: 's3',
          subjectNameOm: 'Science',
          subjectNameEn: 'Science',
          scoreObtained: null, // Unentered
          maxMark: 100.0,
        ),
        const SubjectScoreEntry(
          subjectId: 's4',
          subjectNameOm: 'Oromoo',
          subjectNameEn: 'Oromoo',
          scoreObtained: null, // Unentered
          maxMark: 100.0,
        ),
      ];

      final plan = GradeCalculatorService.planTarget(
        entries: entries,
        targetPercentage: 75.0,
      );

      expect(plan.isAchievable, true);
      expect(plan.isAlreadyMet, false);
      expect(plan.remainingSubjectsCount, 2);
      expect(plan.requiredAverageOnRemaining, 80.0);
    });

    test('identifies when target is already met even if remaining subjects are 0', () {
      // 2 subjects: 100 each. Target = 40%. Student got 90 in first subject.
      // Target total = 80 points. Student has 90. Target already met!
      final entries = [
        const SubjectScoreEntry(
          subjectId: 's1',
          subjectNameOm: 'Herrega',
          subjectNameEn: 'Math',
          scoreObtained: 90.0,
          maxMark: 100.0,
        ),
        const SubjectScoreEntry(
          subjectId: 's2',
          subjectNameOm: 'English',
          subjectNameEn: 'English',
          scoreObtained: null,
          maxMark: 100.0,
        ),
      ];

      final plan = GradeCalculatorService.planTarget(
        entries: entries,
        targetPercentage: 40.0,
      );

      expect(plan.isAchievable, true);
      expect(plan.isAlreadyMet, true);
      expect(plan.requiredAverageOnRemaining, 0.0);
    });

    test('detects when target is mathematically unreachable (>100% required)', () {
      // 2 subjects of 100. Target = 90% (180 points needed).
      // Student got 60 on first subject.
      // Points needed in second subject = 120 / 100 = 120% (impossible!)
      final entries = [
        const SubjectScoreEntry(
          subjectId: 's1',
          subjectNameOm: 'Herrega',
          subjectNameEn: 'Math',
          scoreObtained: 60.0,
          maxMark: 100.0,
        ),
        const SubjectScoreEntry(
          subjectId: 's2',
          subjectNameOm: 'English',
          subjectNameEn: 'English',
          scoreObtained: null,
          maxMark: 100.0,
        ),
      ];

      final plan = GradeCalculatorService.planTarget(
        entries: entries,
        targetPercentage: 90.0,
      );

      expect(plan.isAchievable, false);
      expect(plan.isAlreadyMet, false);
      expect(plan.requiredAverageOnRemaining, 120.0);
    });

    test('evaluates completed scenario where all subjects are already filled', () {
      final entries = [
        const SubjectScoreEntry(
          subjectId: 's1',
          subjectNameOm: 'Herrega',
          subjectNameEn: 'Math',
          scoreObtained: 85.0,
          maxMark: 100.0,
        ),
        const SubjectScoreEntry(
          subjectId: 's2',
          subjectNameOm: 'English',
          subjectNameEn: 'English',
          scoreObtained: 75.0,
          maxMark: 100.0,
        ),
      ];

      final metPlan = GradeCalculatorService.planTarget(
        entries: entries,
        targetPercentage: 70.0,
      );
      expect(metPlan.isAchievable, true);
      expect(metPlan.isAlreadyMet, true);
      expect(metPlan.remainingSubjectsCount, 0);

      final unmetPlan = GradeCalculatorService.planTarget(
        entries: entries,
        targetPercentage: 85.0,
      );
      expect(unmetPlan.isAchievable, false);
      expect(unmetPlan.isAlreadyMet, false);
    });
  });
}
