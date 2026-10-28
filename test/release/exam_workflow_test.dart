import 'package:flutter_test/flutter_test.dart';
import 'package:lamif_grade_8/features/exams/models/question_schema.dart';
import 'package:lamif_grade_8/features/exams/models/exam_result_schema.dart';
import 'package:lamif_grade_8/features/exams/providers/exam_notifier.dart';
import 'package:lamif_grade_8/features/exams/providers/exam_state.dart';
import 'package:lamif_grade_8/features/exams/services/exam_isar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ExamIsarService isarService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    isarService = ExamIsarService(); // In-memory fallback mode for testing
  });

  group('Release Workflow 1: Exam Initialization & State', () {
    test('starts exam, loads questions, and initializes countdown timer', () async {
      final notifier = ExamNotifier(
        isarService: isarService,
        defaultSubjectId: 'herrega',
        defaultSubjectTitle: 'Herrega',
        defaultDurationMinutes: 60,
      );

      await notifier.startExam(subjectId: 'herrega', durationMinutes: 60);

      expect(notifier.state.status, ExamStatus.inProgress);
      expect(notifier.state.questions.isNotEmpty, true);
      expect(notifier.state.currentQuestionIndex, 0);
      expect(notifier.state.remainingSeconds, 3600);
      expect(notifier.state.totalQuestions, greaterThan(0));

      notifier.dispose();
    });
  });

  group('Release Workflow 2: Immediate Draft Persistence & Kill Restore', () {
    test('persists answer draft on tap and seamlessly restores on restart', () async {
      final notifier = ExamNotifier(
        isarService: isarService,
        defaultSubjectId: 'herrega',
      );

      await notifier.startExam(subjectId: 'herrega');
      expect(notifier.state.selectedAnswers.isEmpty, true);

      // Student taps Option B (index 1) on Question 0
      notifier.selectAnswer(0, 1);
      expect(notifier.state.selectedAnswers[0], 1);

      // Verify draft was written to disk
      final savedDrafts = await isarService.loadAnswerDrafts('herrega');
      expect(savedDrafts[0], 1);

      // Simulate App Kill / Interruption / Crash
      notifier.dispose();

      // Launch new session: starting exam must restore Question 0's selection
      final restoredNotifier = ExamNotifier(
        isarService: isarService,
        defaultSubjectId: 'herrega',
      );

      await restoredNotifier.startExam(subjectId: 'herrega');
      expect(restoredNotifier.state.selectedAnswers[0], 1);

      restoredNotifier.dispose();
    });
  });

  group('Release Workflow 3: Question Navigation & Finishing Exam', () {
    test('advances questions and clears draft answers upon completion', () async {
      final notifier = ExamNotifier(
        isarService: isarService,
        defaultSubjectId: 'herrega',
      );

      await notifier.startExam(subjectId: 'herrega');

      // Answer question 0
      notifier.selectAnswer(0, 0);
      notifier.nextQuestion();
      expect(notifier.state.currentQuestionIndex, 1);

      notifier.previousQuestion();
      expect(notifier.state.currentQuestionIndex, 0);

      // Jump via Question Palette
      notifier.goToQuestion(3);
      expect(notifier.state.currentQuestionIndex, 3);

      // Finish exam
      final result = await notifier.endExam();
      expect(result, isNotNull);
      expect(notifier.state.status, ExamStatus.completed);

      // Verify drafts were cleaned up
      final remainingDrafts = await isarService.loadAnswerDrafts('herrega');
      expect(remainingDrafts.isEmpty, true);

      notifier.dispose();
    });
  });

  group('Release Workflow 4: Offline Answering & Sync Queue Flags', () {
    test('exam result is saved locally with isSynced = false for background sync', () async {
      final result = ExamResult(
        subjectId: 'afaan_oromoo',
        score: 38,
        totalQuestions: 40,
        timeTaken: 1800,
        dateTaken: DateTime.now(),
        isSynced: false,
      );

      final id = await isarService.saveExamResult(result);
      expect(id, greaterThan(0));

      final unsynced = await isarService.getUnsyncedExamResults();
      expect(unsynced.any((r) => r.subjectId == 'afaan_oromoo'), true);

      // Simulate successful sync acknowledging ID
      await isarService.markExamResultSynced(id);

      final remainingUnsynced = await isarService.getUnsyncedExamResults();
      expect(remainingUnsynced.where((r) => r.id == id).isEmpty, true);
    });
  });

  group('Release Workflow 5: Schema Serialization & Integrity', () {
    test('Question and Option models correctly serialize to JSON for backup', () {
      final question = Question.create(
        id: 101,
        text: 'Mootummaan naannoo Oromiyaa godinoota meeqa qaba?',
        subjectId: 'hawaasa',
        explanation: 'Oromiyaan godinoota 21 qabdi.',
        options: [
          Option(text: '18', isCorrect: false),
          Option(text: '20', isCorrect: false),
          Option(text: '21', isCorrect: true),
          Option(text: '22', isCorrect: false),
        ],
      );

      final json = question.toJson();
      expect(json['id'], 101);
      expect(json['subjectId'], 'hawaasa');
      expect(question.correctOptionIndex, 2);

      final restored = Question.fromJson(json);
      expect(restored.text, question.text);
      expect(restored.correctOptionIndex, 2);
    });
  });
}
