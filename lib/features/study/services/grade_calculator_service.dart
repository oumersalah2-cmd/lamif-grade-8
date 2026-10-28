import '../config/grade_scale_config.dart';
import '../models/grade_calculation_model.dart';

/// Pure computational service for Grade 8 scores, averages, and target planning
class GradeCalculatorService {
  /// Computes summary, average percentage, pass/fail and tier
  static GradeSummaryResult calculateSummary({
    required List<SubjectScoreEntry> entries,
    double passingThreshold = GradeScaleConfig.defaultPassingPercentage,
  }) {
    if (entries.isEmpty) {
      return GradeSummaryResult(
        totalObtained: 0.0,
        totalMax: 0.0,
        averagePercentage: 0.0,
        isPassed: false,
        tier: GradeScaleConfig.resolveTier(0.0),
        totalSubjectsCount: 0,
        enteredSubjectsCount: 0,
      );
    }

    double totalObtained = 0.0;
    double totalMax = 0.0;
    int enteredCount = 0;

    for (final entry in entries) {
      if (entry.hasScore && entry.maxMark > 0) {
        totalObtained += entry.scoreObtained!;
        totalMax += entry.maxMark;
        enteredCount++;
      }
    }

    final double averagePercentage =
        totalMax > 0 ? (totalObtained / totalMax) * 100.0 : 0.0;
    final bool isPassed = enteredCount > 0 && averagePercentage >= passingThreshold;
    final GradeAchievementTier tier = GradeScaleConfig.resolveTier(averagePercentage);

    return GradeSummaryResult(
      totalObtained: totalObtained,
      totalMax: totalMax,
      averagePercentage: double.parse(averagePercentage.toStringAsFixed(1)),
      isPassed: isPassed,
      tier: tier,
      totalSubjectsCount: entries.length,
      enteredSubjectsCount: enteredCount,
    );
  }

  /// Calculates the required score across unentered subjects to reach a target average
  static TargetPlannerResult planTarget({
    required List<SubjectScoreEntry> entries,
    required double targetPercentage,
  }) {
    // Clamp target between 0 and 100
    final clampedTarget = targetPercentage.clamp(0.0, 100.0);

    if (entries.isEmpty) {
      return TargetPlannerResult(
        targetPercentage: clampedTarget,
        requiredAverageOnRemaining: 0.0,
        isAchievable: false,
        isAlreadyMet: false,
        remainingSubjectsCount: 0,
        messageOm: 'Gosti barnootaa tokkollee hin jiru.',
        messageEn: 'No subjects defined to calculate.',
      );
    }

    final entered = entries.where((e) => e.hasScore && e.maxMark > 0).toList();
    final remaining = entries.where((e) => !e.hasScore && e.maxMark > 0).toList();

    double totalPossibleMax = 0.0;
    double currentObtained = 0.0;

    for (final e in entries) {
      if (e.maxMark > 0) totalPossibleMax += e.maxMark;
      if (e.hasScore) currentObtained += e.scoreObtained!;
    }

    if (totalPossibleMax <= 0) {
      return TargetPlannerResult(
        targetPercentage: clampedTarget,
        requiredAverageOnRemaining: 0.0,
        isAchievable: false,
        isAlreadyMet: false,
        remainingSubjectsCount: 0,
        messageOm: 'Qabxiin guddaan barnootaa sirrii miti.',
        messageEn: 'Invalid subject maximum marks.',
      );
    }

    // Target total points required across all subjects
    final double targetTotalPoints = (clampedTarget / 100.0) * totalPossibleMax;
    final double pointsNeeded = targetTotalPoints - currentObtained;

    // Case 1: All subjects already entered
    if (remaining.isEmpty) {
      final currentAvg = (currentObtained / totalPossibleMax) * 100.0;
      final bool met = currentAvg >= clampedTarget;
      return TargetPlannerResult(
        targetPercentage: clampedTarget,
        requiredAverageOnRemaining: 0.0,
        isAchievable: met,
        isAlreadyMet: met,
        remainingSubjectsCount: 0,
        messageOm: met
            ? 'Barnoota hunda xumurteetta! Karoora kee milkeessiteetta (${currentAvg.toStringAsFixed(1)}%).'
            : 'Barnoota hunda xumurteetta, garuu qabxiin kee (${currentAvg.toStringAsFixed(1)}%) karoora (${clampedTarget.toStringAsFixed(1)}%) gadi.',
        messageEn: met
            ? 'All subjects completed! Target achieved (${currentAvg.toStringAsFixed(1)}%).'
            : 'All subjects completed, but score (${currentAvg.toStringAsFixed(1)}%) is below target (${clampedTarget.toStringAsFixed(1)}%).',
      );
    }

    double remainingMaxSum = 0.0;
    for (final r in remaining) {
      remainingMaxSum += r.maxMark;
    }

    // Case 2: Target is already mathematically secured even with 0 in remaining
    if (pointsNeeded <= 0) {
      return TargetPlannerResult(
        targetPercentage: clampedTarget,
        requiredAverageOnRemaining: 0.0,
        isAchievable: true,
        isAlreadyMet: true,
        remainingSubjectsCount: remaining.length,
        messageOm:
            "Qabxii amma qabduun karoora kee (${clampedTarget.toStringAsFixed(1)}%) qaqqabdeetta! Barnoota hafan keessatti qabxii kamiyyuu yoo fidde ni dabarata.",
        messageEn:
            'You have already secured your target average (${clampedTarget.toStringAsFixed(1)}%) with current entered marks!',
      );
    }

    final double requiredPercentage = (pointsNeeded / remainingMaxSum) * 100.0;

    // Case 3: Target is mathematically impossible (requires > 100%)
    if (requiredPercentage > 100.0) {
      return TargetPlannerResult(
        targetPercentage: clampedTarget,
        requiredAverageOnRemaining: double.parse(requiredPercentage.toStringAsFixed(1)),
        isAchievable: false,
        isAlreadyMet: false,
        remainingSubjectsCount: remaining.length,
        messageOm:
            "Karoora kana (${clampedTarget.toStringAsFixed(1)}%) qaqqabuun hin danda'amu (barnoota hafan ${remaining.length} keessatti ${requiredPercentage.toStringAsFixed(1)}% barbaachisa). Mee karoora kee xiqqoo gadi buusi.",
        messageEn:
            'Target is mathematically unreachable (${requiredPercentage.toStringAsFixed(1)}% needed in remaining ${remaining.length} subjects). Consider adjusting your target.',
      );
    }

    // Case 4: Target is realistically achievable
    final formattedReq = requiredPercentage.toStringAsFixed(1);
    return TargetPlannerResult(
      targetPercentage: clampedTarget,
      requiredAverageOnRemaining: double.parse(formattedReq),
      isAchievable: true,
      isAlreadyMet: false,
      remainingSubjectsCount: remaining.length,
      messageOm:
          "Karoora ${clampedTarget.toStringAsFixed(1)}% qaqqabuuf, barnoota hafan ${remaining.length} keessatti giddu-galeessaan $formattedReq% galmeessisuu qabda.",
      messageEn:
          'To reach your target of ${clampedTarget.toStringAsFixed(1)}%, you need an average of $formattedReq% in the remaining ${remaining.length} subjects.',
    );
  }
}
