import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/grade_scale_config.dart';
import '../models/grade_calculation_model.dart';
import '../providers/grade_calculator_provider.dart';

/// Grade 8 Exam Score Calculator & Target Planner Screen
/// Bilingual: Afaan Oromoo / English.
/// Fully offline-first, optimized for low-end Android mobile touchscreens.
class GradeCalculatorScreen extends ConsumerStatefulWidget {
  const GradeCalculatorScreen({super.key});

  @override
  ConsumerState<GradeCalculatorScreen> createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends ConsumerState<GradeCalculatorScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String id, double? score) {
    if (!_controllers.containsKey(id)) {
      _controllers[id] = TextEditingController(
        text: score != null ? score.toStringAsFixed(0) : '',
      );
    }
    return _controllers[id]!;
  }

  void _syncControllersWithState(List<SubjectScoreEntry> subjects) {
    for (final s in subjects) {
      if (_controllers.containsKey(s.subjectId)) {
        final expected = s.scoreObtained != null ? s.scoreObtained!.toStringAsFixed(0) : '';
        if (_controllers[s.subjectId]!.text != expected) {
          _controllers[s.subjectId]!.text = expected;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gradeCalculatorProvider);
    final notifier = ref.read(gradeCalculatorProvider.notifier);
    final theme = Theme.of(context);

    // Keep controller text updated if auto-filled
    _syncControllersWithState(state.subjects);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Shallaggii Qabxii Kutaa 8ffaa',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Grade 8 Score Calculator & Target Planner',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Haquu (Reset)',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              for (final c in _controllers.values) {
                c.clear();
              }
              notifier.resetScores();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Qabxiileen hundi haqamaniiru (All marks cleared).'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Overall Summary Card (Total, Average, Pass/Fail Badge)
              _buildSummaryHeaderCard(context, state.summary),

              const SizedBox(height: 14),

              // 2. Auto-Fill Action Banner
              _buildAutoFillBanner(context, notifier),

              const SizedBox(height: 16),

              // 3. Target Planner Card
              _buildTargetPlannerCard(context, state, notifier),

              const SizedBox(height: 20),

              // 4. Section Header: Subject Inputs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Qabxii Barnootaa Galchi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    '(${state.summary.enteredSubjectsCount}/${state.summary.totalSubjectsCount})',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter marks obtained out of maximum (100)',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),

              // 5. Subject List Cards
              ...state.subjects.map((subject) {
                return _buildSubjectRowCard(context, subject, notifier);
              }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Overall Summary Card
  Widget _buildSummaryHeaderCard(BuildContext context, GradeSummaryResult summary) {
    final tier = summary.tier;
    final color = Color(tier.colorHex);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Average Percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Giddu-galeessa (Average)',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.averagePercentage}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: summary.isPassed ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),

              // Pass / Fail & Tier Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                      summary.isPassed ? 'DARBEERA (PASS)' : 'KUFEERA (FAIL)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sadarkaa: ${tier.letterGrade}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Qabxii Guutuu', '${summary.totalObtained.toStringAsFixed(0)} / ${summary.totalMax.toStringAsFixed(0)}'),
              _buildStatItem('Barnoota Galfame', '${summary.enteredSubjectsCount} / ${summary.totalSubjectsCount}'),
              _buildStatItem('Madaallii', tier.titleOm),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
    );
  }

  /// 2. Auto-Fill Action Banner
  Widget _buildAutoFillBanner(BuildContext context, GradeCalculatorNotifier notifier) {
    return Semantics(
      button: true,
      label: 'Qabxii Qormaata Shaakalaa Irraa Guuti (Auto-fill from best practice exams)',
      child: Material(
        color: const Color(0xFFEFF6FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFBFDBFE)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final count = await notifier.autoFillFromBestExamScores();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF1E3A8A),
                  content: Text(
                    count > 0
                        ? "Qabxiileen barnoota $count qormaata shaakalaa irraa guutamaniiru!"
                        : 'Qormaanni shaakalaa duraan xumurame hin jiru (No past exams found).',
                  ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF2563EB), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Qabxii Qormaata Shaakalaa Irraa Guuti',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A8A)),
                      ),
                      Text(
                        'Auto-fill using your highest score from practice tests',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF3B82F6)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF2563EB)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 3. Target Planner Card
  Widget _buildTargetPlannerCard(
    BuildContext context,
    GradeCalculatorState state,
    GradeCalculatorNotifier notifier,
  ) {
    final plan = state.targetPlan;
    final isAchievable = plan.isAchievable;
    final planColor = plan.isAlreadyMet
        ? const Color(0xFF15803D)
        : (isAchievable ? const Color(0xFF0284C7) : const Color(0xFFDC2626));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.flag_rounded, color: Color(0xFF0284C7), size: 20),
              SizedBox(width: 8),
              Text(
                'Karoora Qabxii (Target Planner)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Karoora Giddu-galeessaa: ${state.targetPercentage.toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
              Text(
                'Hafan: ${plan.remainingSubjectsCount}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          Slider(
            value: state.targetPercentage,
            min: 50.0,
            max: 95.0,
            divisions: 9,
            activeColor: const Color(0xFF0284C7),
            label: '${state.targetPercentage.toStringAsFixed(0)}%',
            onChanged: (val) => notifier.setTargetPercentage(val),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: planColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: planColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      plan.isAlreadyMet ? Icons.check_circle : (isAchievable ? Icons.info : Icons.warning_amber),
                      color: planColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      plan.isAlreadyMet
                          ? 'Karoorri Milkaa\'eera!'
                          : (isAchievable
                              ? 'Qabxii Hafan Keessatti Barbaachisu: ${plan.requiredAverageOnRemaining}%'
                              : 'Hin Danda\'amu (Unreachable)'),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: planColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  plan.messageOm,
                  style: TextStyle(fontSize: 12, color: planColor.withOpacity(0.9), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Subject Input Row Card
  Widget _buildSubjectRowCard(
    BuildContext context,
    SubjectScoreEntry subject,
    GradeCalculatorNotifier notifier,
  ) {
    final controller = _getController(subject.subjectId, subject.scoreObtained);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: subject.hasScore ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // Subject Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.subjectNameOm,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                ),
                Text(
                  '${subject.subjectNameEn} • Max: ${subject.maxMark.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          // Percentage indicator if entered
          if (subject.hasScore)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                '${subject.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: subject.percentage >= 50 ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                ),
              ),
            ),

          // Accessible Text Field with Min 48x48dp Touch Target
          Semantics(
            label: 'Qabxii ${subject.subjectNameOm} galchi',
            textField: true,
            child: SizedBox(
              width: 76,
              height: 48, // Accessibility touch target compliance
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '0-${subject.maxMark.toStringAsFixed(0)}',
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val.trim());
                  if (parsed != null && parsed >= 0 && parsed <= subject.maxMark) {
                    notifier.updateScore(subject.subjectId, parsed);
                  } else if (val.trim().isEmpty) {
                    notifier.updateScore(subject.subjectId, null);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
