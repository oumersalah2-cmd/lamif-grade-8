import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_notifier.dart';
import '../screens/exam_screen.dart';

/// Catalog of Grade 8 Ministry Examinations and Ifa Boru Special Entrance Exams.
/// Students can select any subject or past year exam to start an offline exam session.
class ExamCatalogScreen extends ConsumerWidget {
  const ExamCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showIfaBoru = ref.watch(shouldShowIfaBoruProvider);
    final showMinistry = ref.watch(shouldShowMinistryProvider);
    final theme = Theme.of(context);

    final ministryExams = [
      {
        'id': 'afaan_oromoo',
        'title': 'Afaan Oromoo',
        'desc': 'Caasluga, Mamaksa, Og-barruu fi Dubbisa',
        'questions': 40,
        'duration': 60,
        'color': const Color(0xFF15803D),
        'icon': Icons.menu_book_rounded,
      },
      {
        'id': 'herrega',
        'title': 'Herrega (Mathematics)',
        'desc': 'Aljebraa, Ji\'oomeetirii, Paayitaagorasii fi Shallaggii',
        'questions': 40,
        'duration': 60,
        'color': const Color(0xFF0D47A1),
        'icon': Icons.calculate_rounded,
      },
      {
        'id': 'saayinsii_waliigalaa',
        'title': 'Saayinsii Waliigalaa',
        'desc': 'Fiiziksii, Keemistirii fi Baayoloojii Bu\'uuraa',
        'questions': 40,
        'duration': 60,
        'color': const Color(0xFF0F766E),
        'icon': Icons.science_rounded,
      },
      {
        'id': 'saayinsii_hawaasaa',
        'title': 'Saayinsii Hawaasaa',
        'desc': 'Seenaa, Joogiraafii fi Lammummaa',
        'questions': 40,
        'duration': 60,
        'color': const Color(0xFFB45309),
        'icon': Icons.public_rounded,
      },
      {
        'id': 'english',
        'title': 'Ingiliffa (English Language)',
        'desc': 'Grammar, Vocabulary, Reading Comprehension',
        'questions': 40,
        'duration': 60,
        'color': const Color(0xFF6D28D9),
        'icon': Icons.language_rounded,
      },
    ];

    final ifaBoruExams = [
      {
        'id': 'ifa_boru_aptitude',
        'title': 'Sammuu-Qara (Aptitude Test)',
        'desc': 'Yaada Sammuu, Xiinxala Herregaa fi Logic',
        'questions': 30,
        'duration': 45,
        'color': const Color(0xFF1E3A8A),
        'icon': Icons.psychology_rounded,
      },
      {
        'id': 'ifa_boru_adv_math',
        'title': 'Herrega Addaa Ifa Boruu',
        'desc': 'Qormaata Dorgommii Barumsa Bultii Addaa',
        'questions': 35,
        'duration': 50,
        'color': const Color(0xFF047857),
        'icon': Icons.auto_awesome_rounded,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Qormaata Kutaa 8ffaa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Seenaa Qormaataa (History)',
            icon: const Icon(Icons.history_edu_rounded),
            onPressed: () => context.push('/exam-history'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Top Quick Action: History and Practice Banner
            _buildHistoryBanner(context),
            const SizedBox(height: 20),

            // Ministry Exams Section
            if (showMinistry) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Qormaata Naannoo Oromiyaa (Ministry)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.verified, size: 18, color: Color(0xFF15803D)),
                ],
              ),
              const SizedBox(height: 12),
              ...ministryExams.map((exam) => _buildExamCard(context, exam, theme)),
              const SizedBox(height: 20),
            ],

            // Ifa Boru Special Section
            if (showIfaBoru) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Mana Barumsaa Bultii Addaa Ifa Boruu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.workspace_premium_rounded, size: 18, color: Color(0xFF1E3A8A)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Qormaata dorgommii seensa bultii addaa Ifa Boruu',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              ...ifaBoruExams.map((exam) => _buildExamCard(context, exam, theme)),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.analytics_rounded, color: Color(0xFF4ADE80), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Qabxiiwwan Keetiifi Seenaa',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 2),
                Text(
                  'Qormaatawwan kanaan dura shaakalte ilaali',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => context.push('/exam-history'),
            child: const Text('Ilaali', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Map<String, dynamic> exam, ThemeData theme) {
    final color = exam['color'] as Color;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _confirmAndStartExam(context, exam);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(exam['icon'] as IconData, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      exam['desc'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.quiz_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${exam['questions']} Gaaffilee',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${exam['duration']} daqiiqaa',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF15803D).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF15803D), size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmAndStartExam(BuildContext context, Map<String, dynamic> exam) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(exam['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Qormaata kana jalqabuuf qophiidhaa?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('• Baay\'ina gaaffii: ${exam['questions']}'),
            Text('• Yeroo kenname: ${exam['duration']} daqiiqaa'),
            const Text('• Offline: Intarneetii hin barbaadu'),
            const SizedBox(height: 12),
            const Text(
              'Yeroon qormaataa erga jalqabee booda lakkoofsa duubatti (countdown) jalqaba.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Boodatti'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => ExamScreen(
                    subjectId: exam['id'] as String,
                    subjectTitleOm: exam['title'] as String,
                    durationMinutes: exam['duration'] as int,
                  ),
                ),
              );
            },
            child: const Text('Qormaata Jalqabi'),
          ),
        ],
      ),
    );
  }
}
