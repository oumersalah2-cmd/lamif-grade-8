import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exam_attempt_model.dart';
import '../repositories/exam_repository.dart';

/// Subject definition helper for progress tracking
class ProgressSubject {
  final String id;
  final String nameOm;
  final String nameEn;
  final IconData icon;
  final Color accentColor;
  final int totalStandardExams;

  const ProgressSubject({
    required this.id,
    required this.nameOm,
    required this.nameEn,
    required this.icon,
    required this.accentColor,
    this.totalStandardExams = 4,
  });
}

const List<ProgressSubject> grade8Subjects = [
  ProgressSubject(
    id: 'afaan_oromoo',
    nameOm: 'Afaan Oromoo',
    nameEn: 'Afaan Oromoo',
    icon: Icons.menu_book,
    accentColor: Color(0xFF16A34A),
  ),
  ProgressSubject(
    id: 'herrega',
    nameOm: 'Herrega',
    nameEn: 'Mathematics',
    icon: Icons.calculate,
    accentColor: Color(0xFF2563EB),
  ),
  ProgressSubject(
    id: 'saayinsii_waliigalaa',
    nameOm: 'Saayinsii Waliigalaa',
    nameEn: 'General Science',
    icon: Icons.science,
    accentColor: Color(0xFF7C3AED),
  ),
  ProgressSubject(
    id: 'saayinsii_hawaasaa',
    nameOm: 'Saayinsii Hawaasaa',
    nameEn: 'Social Studies',
    icon: Icons.public,
    accentColor: Color(0xFFEA580C),
  ),
  ProgressSubject(
    id: 'lammummaa',
    nameOm: 'Barnoota Lammummaa',
    nameEn: 'Citizenship',
    icon: Icons.gavel,
    accentColor: Color(0xFF0D9488),
  ),
  ProgressSubject(
    id: 'english',
    nameOm: 'Afaan Ingilizii',
    nameEn: 'English Language',
    icon: Icons.language,
    accentColor: Color(0xFFD97706),
  ),
];

/// Computed state class representing student progress breakdown
class StudentExamProgressState {
  final List<SubjectProgressSummary> completedSubjects;
  final List<ProgressSubject> pendingSubjects;
  final int totalAttemptsCount;
  final double overallAverageScore;
  final double curriculumProgressRatio;

  const StudentExamProgressState({
    required this.completedSubjects,
    required this.pendingSubjects,
    required this.totalAttemptsCount,
    required this.overallAverageScore,
    required this.curriculumProgressRatio,
  });
}

class SubjectProgressSummary {
  final ProgressSubject subject;
  final int attemptsCount;
  final int highestScore;
  final int latestScore;
  final DateTime latestAttemptDate;
  final bool hasPendingSync;

  const SubjectProgressSummary({
    required this.subject,
    required this.attemptsCount,
    required this.highestScore,
    required this.latestScore,
    required this.latestAttemptDate,
    required this.hasPendingSync,
  });
}

/// Riverpod provider computing progress from local exam attempts history
final examProgressSummaryProvider = Provider<AsyncValue<StudentExamProgressState>>((ref) {
  final historyAsync = ref.watch(examHistoryProvider);

  return historyAsync.whenData((attempts) {
    final Map<String, List<ExamAttemptModel>> grouped = {};
    for (final a in attempts) {
      grouped.putIfAbsent(a.subjectId, () => []).add(a);
    }

    final List<SubjectProgressSummary> completed = [];
    final List<ProgressSubject> pending = [];

    for (final subj in grade8Subjects) {
      final subjectAttempts = grouped[subj.id];
      if (subjectAttempts != null && subjectAttempts.isNotEmpty) {
        subjectAttempts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final latest = subjectAttempts.first;
        final highest = subjectAttempts.map((e) => e.scorePercentage).reduce((a, b) => a > b ? a : b);
        final hasPendingSync = subjectAttempts.any((e) => !e.isSynced);

        completed.add(
          SubjectProgressSummary(
            subject: subj,
            attemptsCount: subjectAttempts.length,
            highestScore: highest,
            latestScore: latest.scorePercentage,
            latestAttemptDate: latest.timestamp,
            hasPendingSync: hasPendingSync,
          ),
        );
      } else {
        pending.add(subj);
      }
    }

    final totalAttempts = attempts.length;
    final avgScore = attempts.isNotEmpty
        ? attempts.map((e) => e.scorePercentage).reduce((a, b) => a + b) / attempts.length
        : 0.0;
    final progressRatio = grade8Subjects.isNotEmpty ? completed.length / grade8Subjects.length : 0.0;

    return StudentExamProgressState(
      completedSubjects: completed,
      pendingSubjects: pending,
      totalAttemptsCount: totalAttempts,
      overallAverageScore: avgScore,
      curriculumProgressRatio: progressRatio,
    );
  });
});

/// Flutter UI Component displaying student progress with Riverpod
class ExamProgressWidget extends ConsumerWidget {
  final void Function(ProgressSubject subject)? onStartPractice;
  final VoidCallback? onSyncRequested;

  const ExamProgressWidget({
    Key? key,
    this.onStartPractice,
    this.onSyncRequested,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(examProgressSummaryProvider);
    final pendingSyncAsync = ref.watch(pendingSyncCountProvider);
    final pendingSyncCount = pendingSyncAsync.value ?? 0;

    return progressAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: Color(0xFF1B6E32)),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Dogoggora odeeffannoo buusuu: ${err.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      data: (progress) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Overall Readiness Header Card
              _buildOverallProgressCard(context, progress, pendingSyncCount),

              const SizedBox(height: 20),

              // 2. Completed Subjects Section
              _buildSectionTitle(
                context,
                title: 'Gosoota Barnootaa Xumuraman',
                subtitle: 'Completed Subjects (${progress.completedSubjects.length}/${grade8Subjects.length})',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF16A34A),
              ),

              const SizedBox(height: 10),

              if (progress.completedSubjects.isEmpty)
                _buildEmptyStateCard(
                  message: 'Hammamtuu qormaanni xumurame hin jiru. Shaakala jalqabaa filadhaa!',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: progress.completedSubjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = progress.completedSubjects[index];
                    return _buildCompletedSubjectCard(context, item);
                  },
                ),

              const SizedBox(height: 24),

              // 3. Pending Practice Tests Section
              _buildSectionTitle(
                context,
                title: 'Shaakala Hafan (Pending Practice Tests)',
                subtitle: 'Gosoota qormaata ministry qophaa\'uuf hafan (${progress.pendingSubjects.length})',
                icon: Icons.pending_actions,
                color: const Color(0xFFD97706),
              ),

              const SizedBox(height: 10),

              if (progress.pendingSubjects.isEmpty)
                _buildAllCompletedCard()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: progress.pendingSubjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final subj = progress.pendingSubjects[index];
                    return _buildPendingSubjectCard(context, subj);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverallProgressCard(
    BuildContext context,
    StudentExamProgressState progress,
    int pendingSyncCount,
  ) {
    final percentage = (progress.curriculumProgressRatio * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B6E32), Color(0xFF0F471E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B6E32).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Qophii Qormaata Naannoo',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Gamaaggama Qabxii Barataa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Color(0xFFFFD54F),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.curriculumProgressRatio,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
            ),
          ),

          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderStatItem(
                label: 'Qormaata Fudhatame',
                value: '${progress.totalAttemptsCount}',
              ),
              _buildHeaderStatItem(
                label: 'Qabxii Giddu-galeessaa',
                value: '${progress.overallAverageScore.toStringAsFixed(1)}%',
              ),
              _buildHeaderStatItem(
                label: 'Gosoota Hafan',
                value: '${progress.pendingSubjects.length}',
              ),
            ],
          ),

          if (pendingSyncCount > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_upload_outlined, color: Color(0xFFFFD54F), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Qabxiin $pendingSyncCount offline kuufameera (Pending sync)',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  if (onSyncRequested != null)
                    InkWell(
                      onTap: onSyncRequested,
                      child: const Text(
                        'Qindeessi',
                        style: TextStyle(
                          color: Color(0xFFFFD54F),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderStatItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedSubjectCard(BuildContext context, SubjectProgressSummary item) {
    final subj = item.subject;
    final isHighScore = item.latestScore >= 75;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: subj.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(subj.icon, color: subj.accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subj.nameOm,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Yeroo ${item.attemptsCount} fudhatame • Qabxii ol\'aanaa: ${item.highestScore}%',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // Score Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isHighScore ? const Color(0xFFD4EDDA) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  '${item.latestScore}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isHighScore ? const Color(0xFF155D27) : const Color(0xFFB45309),
                  ),
                ),
                Text(
                  isHighScore ? 'Darbiinsa' : 'Shaakali',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isHighScore ? const Color(0xFF155D27) : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSubjectCard(BuildContext context, ProgressSubject subj) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(subj.icon, color: Colors.grey.shade600, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subj.nameOm,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Qormaanni hin eegalle • Kutaa 8ffaa',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => onStartPractice?.call(subj),
            style: ElevatedButton.styleFrom(
              backgroundColor: subj.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedCornerShape(10),
            ),
            child: const Text(
              'Shaakali',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard({required String message}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildAllCompletedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4EDDA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.emoji_events, color: Color(0xFF155D27), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Baga gammaddan! Gosoota barnootaa hundaaf shaakala fudhattaniittu. Qormaata Ministry qophiidha!',
              style: TextStyle(
                color: Color(0xFF155D27),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
