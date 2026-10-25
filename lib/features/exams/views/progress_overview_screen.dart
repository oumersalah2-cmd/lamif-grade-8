import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/exam_repository.dart';
import '../widgets/exam_progress_widget.dart';
import '../screens/exam_history_screen.dart';

class ProgressOverviewScreen extends ConsumerWidget {
  const ProgressOverviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Gamaaggama Qophii Qormaataa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: const Color(0xFF1B6E32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Seenaa Qormaataa (Exam History)',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ExamHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Qindeessi (Sync)',
            onPressed: () async {
              final repo = ref.read(examRepositoryProvider);
              final synced = await repo.syncPendingResults();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      synced > 0
                          ? 'Qabxii $synced gara duumessaatti qindaa\'eera!'
                          : 'Qabxiin haaraan qindaa\'u hin jiru.',
                    ),
                    backgroundColor: const Color(0xFF1B6E32),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ExamProgressWidget(
          onStartPractice: (subject) {
            // Trigger practice exam flow for selected pending subject
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Shaakala ${subject.nameOm} eegaluuf qophii...'),
                backgroundColor: subject.accentColor,
              ),
            );
          },
          onSyncRequested: () async {
            final repo = ref.read(examRepositoryProvider);
            await repo.syncPendingResults();
          },
        ),
      ),
    );
  }
}
