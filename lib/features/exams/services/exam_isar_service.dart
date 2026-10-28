import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_schema.dart';
import '../models/exam_result_schema.dart';
import '../models/user_progress_schema.dart';

/// Abstract service defining Isar database interactions for offline exams
abstract class IExamIsarService {
  Future<List<Question>> getQuestionsBySubject(String subjectId);
  Future<List<Question>> getAllQuestions();
  Future<List<Question>> searchQuestions(String query, {String? subjectId});
  Future<void> saveQuestions(List<Question> questions);
  
  // ExamResult operations with offline-first isSynced flag
  Future<Id> saveExamResult(ExamResult result);
  Future<List<ExamResult>> getAllExamResults();
  Future<List<ExamResult>> getResultsBySubject(String subjectId);
  Future<List<ExamResult>> getUnsyncedExamResults();
  Future<void> markExamResultSynced(Id resultId);
  Stream<List<ExamResult>> watchExamResults();

  // UserProgress operations with offline-first isSynced flag
  Future<Id> saveUserProgress(UserProgress progress);
  Future<List<UserProgress>> getAllUserProgress();
  Future<UserProgress?> getUserProgressBySubject(String subjectId);
  Future<List<UserProgress>> getUnsyncedUserProgress();
  Future<void> markUserProgressSynced(Id progressId);

  // Immediate tap persistence for active exam crash tolerance
  Future<void> saveAnswerDraft(String subjectId, int questionIndex, int optionIndex);
  Future<Map<int, int>> loadAnswerDrafts(String subjectId);
  Future<void> clearAnswerDrafts(String subjectId);
}

/// Robust offline Isar implementation with persistent caching and seeds
class ExamIsarService implements IExamIsarService {
  final Isar? _isar;
  final Map<String, List<Question>> _fallbackQuestionCache = {};
  final List<ExamResult> _fallbackResultsCache = [];
  final List<UserProgress> _fallbackProgressCache = [];
  final StreamController<List<ExamResult>> _resultsStreamController =
      StreamController<List<ExamResult>>.broadcast();

  ExamIsarService([this._isar]) {
    _seedDefaultGrade8Questions();
    _seedSampleExamResultsIfEmpty();
    _seedSampleUserProgressIfEmpty();
  }

  @override
  Future<List<Question>> getAllQuestions() async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      try {
        final all = await isar.questions.where().findAll();
        if (all.isNotEmpty) return all;
      } catch (_) {}
    }
    final allList = <Question>[];
    for (final list in _fallbackQuestionCache.values) {
      allList.addAll(list);
    }
    return allList;
  }

  @override
  Future<List<Question>> searchQuestions(String query, {String? subjectId}) async {
    final lowerQ = query.trim().toLowerCase();
    final all = await getAllQuestions();
    return all.where((q) {
      if (subjectId != null && subjectId.isNotEmpty && q.subjectId.toLowerCase() != subjectId.toLowerCase()) {
        return false;
      }
      if (lowerQ.isEmpty) return true;
      final textMatch = q.text.toLowerCase().contains(lowerQ);
      final explanationMatch = q.explanation.toLowerCase().contains(lowerQ);
      final optionsMatch = q.options.any((opt) => opt.text.toLowerCase().contains(lowerQ));
      return textMatch || explanationMatch || optionsMatch;
    }).toList();
  }

  @override
  Future<List<Question>> getQuestionsBySubject(String subjectId) async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      try {
        final results = await isar.questions
            .filter()
            .subjectIdEqualTo(subjectId)
            .findAll();
        if (results.isNotEmpty) return results;
      } catch (_) {
        // Fallback to in-memory store
      }
    }
    return List<Question>.from(_fallbackQuestionCache[subjectId] ?? []);
  }

  @override
  Future<void> saveQuestions(List<Question> questions) async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      await isar.writeTxn(() async {
        await isar.questions.putAll(questions);
      });
    }

    for (final q in questions) {
      _fallbackQuestionCache.putIfAbsent(q.subjectId, () => []);
      final list = _fallbackQuestionCache[q.subjectId]!;
      list.removeWhere((item) => item.id == q.id && q.id != Isar.autoIncrement);
      list.add(q);
    }
  }

  @override
  Future<Id> saveExamResult(ExamResult result) async {
    // Ensure critical offline-first flag is preserved
    result.isSynced = false;

    final isar = _isar;
    if (isar != null && isar.isOpen) {
      Id insertedId = 0;
      await isar.writeTxn(() async {
        insertedId = await isar.examResults.put(result);
      });
      _notifyResultsChanged();
      return insertedId;
    }

    final id = result.id == Isar.autoIncrement
        ? _fallbackResultsCache.length + 1
        : result.id;
    final saved = result.copyWith(id: id, isSynced: false);
    _fallbackResultsCache.insert(0, saved);
    _notifyResultsChanged();
    return id;
  }

  @override
  Future<List<ExamResult>> getAllExamResults() async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      return await isar.examResults.where().sortByDateTakenDesc().findAll();
    }
    return List<ExamResult>.from(_fallbackResultsCache);
  }

  @override
  Future<List<ExamResult>> getResultsBySubject(String subjectId) async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      return await isar.examResults
          .filter()
          .subjectIdEqualTo(subjectId)
          .sortByDateTakenDesc()
          .findAll();
    }
    return _fallbackResultsCache
        .where((r) => r.subjectId.toLowerCase() == subjectId.toLowerCase())
        .toList();
  }

  @override
  Future<List<ExamResult>> getUnsyncedExamResults() async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      return await isar.examResults
          .filter()
          .isSyncedEqualTo(false)
          .sortByDateTakenDesc()
          .findAll();
    }
    return _fallbackResultsCache.where((r) => !r.isSynced).toList();
  }

  @override
  Future<void> markExamResultSynced(Id resultId) async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      await isar.writeTxn(() async {
        final existing = await isar.examResults.get(resultId);
        if (existing != null) {
          existing.isSynced = true;
          await isar.examResults.put(existing);
        }
      });
    }

    final index = _fallbackResultsCache.indexWhere((r) => r.id == resultId);
    if (index != -1) {
      _fallbackResultsCache[index] =
          _fallbackResultsCache[index].copyWith(isSynced: true);
    }
    _notifyResultsChanged();
  }

  @override
  Stream<List<ExamResult>> watchExamResults() {
    return _resultsStreamController.stream;
  }

  void _notifyResultsChanged() {
    _resultsStreamController.add(List<ExamResult>.from(_fallbackResultsCache));
  }

  @override
  Future<Id> saveUserProgress(UserProgress progress) async {
    // Crucial: offline actions strictly default to isSynced = false
    progress.isSynced = false;

    final isar = _isar;
    if (isar != null && isar.isOpen) {
      Id insertedId = 0;
      await isar.writeTxn(() async {
        insertedId = await isar.userProgress.put(progress);
      });
      return insertedId;
    }

    final id = progress.id == Isar.autoIncrement
        ? _fallbackProgressCache.length + 1
        : progress.id;
    final saved = progress.copyWith(id: id, isSynced: false);
    _fallbackProgressCache.removeWhere((p) => p.subjectId == progress.subjectId);
    _fallbackProgressCache.add(saved);
    return id;
  }

  @override
  Future<List<UserProgress>> getAllUserProgress() async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      return await isar.userProgress.where().findAll();
    }
    return List<UserProgress>.from(_fallbackProgressCache);
  }

  @override
  Future<UserProgress?> getUserProgressBySubject(String subjectId) async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      return await isar.userProgress
          .filter()
          .subjectIdEqualTo(subjectId)
          .findFirst();
    }
    final matches = _fallbackProgressCache
        .where((p) => p.subjectId.toLowerCase() == subjectId.toLowerCase());
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<List<UserProgress>> getUnsyncedUserProgress() async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      return await isar.userProgress
          .filter()
          .isSyncedEqualTo(false)
          .findAll();
    }
    return _fallbackProgressCache.where((p) => !p.isSynced).toList();
  }

  @override
  Future<void> markUserProgressSynced(Id progressId) async {
    final isar = _isar;
    if (isar != null && isar.isOpen) {
      await isar.writeTxn(() async {
        final existing = await isar.userProgress.get(progressId);
        if (existing != null) {
          existing.isSynced = true;
          await isar.userProgress.put(existing);
        }
      });
    }

    final index = _fallbackProgressCache.indexWhere((p) => p.id == progressId);
    if (index != -1) {
      _fallbackProgressCache[index] =
          _fallbackProgressCache[index].copyWith(isSynced: true);
    }
  }

  @override
  Future<void> saveAnswerDraft(String subjectId, int questionIndex, int optionIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'draft_answers_$subjectId';
      final existingJson = prefs.getString(key);
      Map<String, dynamic> map = {};
      if (existingJson != null) {
        try {
          map = Map<String, dynamic>.from(jsonDecode(existingJson) as Map);
        } catch (_) {}
      }
      map[questionIndex.toString()] = optionIndex;
      await prefs.setString(key, jsonEncode(map));
    } catch (e) {
      debugPrint('[ExamIsarService] Error saving answer draft: $e');
    }
  }

  @override
  Future<Map<int, int>> loadAnswerDrafts(String subjectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'draft_answers_$subjectId';
      final existingJson = prefs.getString(key);
      if (existingJson != null) {
        final Map<String, dynamic> raw = Map<String, dynamic>.from(jsonDecode(existingJson) as Map);
        return raw.map((k, v) => MapEntry(int.parse(k), v as int));
      }
    } catch (e) {
      debugPrint('[ExamIsarService] Error loading answer drafts: $e');
    }
    return {};
  }

  @override
  Future<void> clearAnswerDrafts(String subjectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('draft_answers_$subjectId');
    } catch (e) {
      debugPrint('[ExamIsarService] Error clearing answer drafts: $e');
    }
  }

  void _seedSampleUserProgressIfEmpty() {
    if (_fallbackProgressCache.isNotEmpty) return;
    final now = DateTime.now();
    _fallbackProgressCache.addAll([
      UserProgress(
        id: 1,
        userId: 'local_student',
        subjectId: 'herrega',
        totalQuestionsAttempted: 45,
        totalCorrectAnswers: 38,
        totalTimeSpentSeconds: 3600,
        lastStudiedAt: now.subtract(const Duration(hours: 2)),
        isSynced: true,
      ),
      UserProgress(
        id: 2,
        userId: 'local_student',
        subjectId: 'afaan_oromoo',
        totalQuestionsAttempted: 50,
        totalCorrectAnswers: 44,
        totalTimeSpentSeconds: 4200,
        lastStudiedAt: now.subtract(const Duration(days: 1)),
        isSynced: true,
      ),
      UserProgress(
        id: 3,
        userId: 'local_student',
        subjectId: 'saayinsii_waliigalaa',
        totalQuestionsAttempted: 30,
        totalCorrectAnswers: 25,
        totalTimeSpentSeconds: 2400,
        lastStudiedAt: now.subtract(const Duration(days: 2)),
        isSynced: true,
      ),
    ]);
  }

  /// Seed high-quality Grade 8 ministry-aligned mock questions in Afaan Oromoo
  void _seedDefaultGrade8Questions() {
    // 1. HERREGA (Mathematics - Kutaa 8ffaa)
    _fallbackQuestionCache['herrega'] = [
      Question(
        id: 1,
        subjectId: 'herrega',
        text: 'Lakkoofsi raashinaalii kamtu 3/4 fi 5/6 gidduu jiraata?',
        explanation: 'Fakkiif: 3/4 = 0.75 fi 5/6 = 0.833. Gidduu isaanii 19/24 = 0.7916 waan jiruuf deebii sirriidha.',
        options: [
          Option(text: '7/12', isCorrect: false),
          Option(text: '19/24', isCorrect: true),
          Option(text: '11/12', isCorrect: false),
          Option(text: '2/3', isCorrect: false),
        ],
      ),
      Question(
        id: 2,
        subjectId: 'herrega',
        text: 'Hima walqixxummaa 2x + 7 = 19 yoo ta\'e, gatiin x meeqa ta\'a?',
        explanation: '2x = 19 - 7 => 2x = 12 => x = 6.',
        options: [
          Option(text: '4', isCorrect: false),
          Option(text: '5', isCorrect: false),
          Option(text: '6', isCorrect: true),
          Option(text: '8', isCorrect: false),
        ],
      ),
      Question(
        id: 3,
        subjectId: 'herrega',
        text: 'Bal\'inni boca roga-sadoi qajeelaa (right triangle) kan dheerinni hundee 8cm fi dheerinni dhaabbataa 6cm ta\'e meeqa?',
        explanation: 'Bal\'ina = (Hundee × Dhaabbata) / 2 = (8 × 6) / 2 = 48 / 2 = 24 cm².',
        options: [
          Option(text: '48 cm²', isCorrect: false),
          Option(text: '24 cm²', isCorrect: true),
          Option(text: '14 cm²', isCorrect: false),
          Option(text: '28 cm²', isCorrect: false),
        ],
      ),
      Question(
        id: 4,
        subjectId: 'herrega',
        text: 'Humni dhibbeentaa (percentage) 40 keessaa 10 meeqa ta\'a?',
        explanation: '(10 / 40) × 100% = 1/4 × 100% = 25%.',
        options: [
          Option(text: '20%', isCorrect: false),
          Option(text: '25%', isCorrect: true),
          Option(text: '30%', isCorrect: false),
          Option(text: '15%', isCorrect: false),
        ],
      ),
      Question(
        id: 5,
        subjectId: 'herrega',
        text: 'Waqtii rukkina lakkoofsaa: Lakkoofsi 144 gatii iskuweer-ruutii (√144) meeqa qaba?',
        explanation: '12 × 12 = 144 waan ta\'eef, √144 = 12 dha.',
        options: [
          Option(text: '11', isCorrect: false),
          Option(text: '12', isCorrect: true),
          Option(text: '14', isCorrect: false),
          Option(text: '16', isCorrect: false),
        ],
      ),
    ];

    // 2. AFAAN OROMOO (Kutaa 8ffaa)
    _fallbackQuestionCache['afaan_oromoo'] = [
      Question(
        id: 101,
        subjectId: 'afaan_oromoo',
        text: 'Caasaa jechaa keessatti \'Mata-duree fi Gochibsa\' kan qabu maal jedhama?',
        explanation: 'Himi tokko yoo xiqqaate mat-duree fi gochibsa qabaata.',
        options: [
          Option(text: 'Gaalee', isCorrect: false),
          Option(text: 'Hima', isCorrect: true),
          Option(text: 'Dhaamsuu', isCorrect: false),
          Option(text: 'Bamaqaa', isCorrect: false),
        ],
      ),
      Question(
        id: 102,
        subjectId: 'afaan_oromoo',
        text: 'Mammaaksa: "Ija jabaatan ..." kan jedhu kan xumuru kami?',
        explanation: 'Mammaaksi kun "Ija jabaatan fira hin dhaban" jedhama.',
        options: [
          Option(text: 'Kufaatii dhandhamu', isCorrect: false),
          Option(text: 'Fira hin dhaban', isCorrect: true),
          Option(text: 'Dhugaa callisu', isCorrect: false),
          Option(text: 'Milkaa\'ina argatu', isCorrect: false),
        ],
      ),
      Question(
        id: 103,
        subjectId: 'afaan_oromoo',
        text: 'Jechi \'Toltuu\' jedhu faallaa isaatiin maal jedhama?',
        explanation: 'Toltuu (gaarii hojjettu) kan faallaa ta\'e Hamaa ykn Hamtumaadha.',
        options: [
          Option(text: 'Hamtuu', isCorrect: true),
          Option(text: 'Barsiiftuu', isCorrect: false),
          Option(text: 'Bareedduu', isCorrect: false),
          Option(text: 'Gammachiiftuu', isCorrect: false),
        ],
      ),
      Question(
        id: 104,
        subjectId: 'afaan_oromoo',
        text: 'Boca qormaataa keessatti mallattoon gaaffii (?) yoom tajaajila?',
        explanation: 'Hima gaaffii agarsiisuuf xumura himaatti fayyadamna.',
        options: [
          Option(text: 'Xumura hima labsii irratti', isCorrect: false),
          Option(text: 'Hima gaaffii xumuruuf', isCorrect: true),
          Option(text: 'Jechoota gargar qooduuf', isCorrect: false),
          Option(text: 'Hima ajajaa keessatti', isCorrect: false),
        ],
      ),
    ];

    // 3. SAAYINSII WALIIGALAA (General Science)
    _fallbackQuestionCache['saayinsii_waliigalaa'] = [
      Question(
        id: 201,
        subjectId: 'saayinsii_waliigalaa',
        text: 'Uumamni lubbu-qabeeyyii hundaa kan ijaarame bu\'uura maaliitiin?',
        explanation: 'Lubbu-qabeeyyiin hundi seeliidhaan (cell) ijaaraman.',
        options: [
          Option(text: 'Atamii', isCorrect: false),
          Option(text: 'Seelii (Cell)', isCorrect: true),
          Option(text: 'Tishuu', isCorrect: false),
          Option(text: 'Orgaanii', isCorrect: false),
        ],
      ),
      Question(
        id: 202,
        subjectId: 'saayinsii_waliigalaa',
        text: 'Gaazii kamtu adeemsa footoosinteesisiif (fotosinteesisii) biqiltootaaf barbaachisa?',
        explanation: 'Biqiltoonni nyaata qopheeffachuuf Kaarboon-daayooksaayidii (CO2) fudhatu.',
        options: [
          Option(text: 'Oksijiinii', isCorrect: false),
          Option(text: 'Kaarboon-daayooksaayidii', isCorrect: true),
          Option(text: 'Naayitiroojiinii', isCorrect: false),
          Option(text: 'Haayidiroojiinii', isCorrect: false),
        ],
      ),
      Question(
        id: 203,
        subjectId: 'saayinsii_waliigalaa',
        text: 'Humni dachee gara lafaatti wantoota harkisu maal jedhama?',
        explanation: 'Humni harkisa lafaa (Gravity) wantoota hunda gara handhuura lafaatti harkisa.',
        options: [
          Option(text: 'Huma harkisa lafaa (Gravity)', isCorrect: true),
          Option(text: 'Humna shaffisaa', isCorrect: false),
          Option(text: 'Humna dhiibbaa', isCorrect: false),
          Option(text: 'Humna magneettummaa', isCorrect: false),
        ],
      ),
    ];

    // 4. HAWAASUMMAA (Social Studies)
    _fallbackQuestionCache['hawaasummaa'] = [
      Question(
        id: 301,
        subjectId: 'hawaasummaa',
        text: 'Baqqanni qilleensa lafaa kan fiixee lafaatti aanee argamu maal jedhama?',
        explanation: 'Tiroopoosfeeriin (Troposphere) baqqana qilleensaa kan lafatti aanee jiruudha.',
        options: [
          Option(text: 'Tiroopoosfeerii (Troposphere)', isCorrect: true),
          Option(text: 'Istratifeerii (Stratosphere)', isCorrect: false),
          Option(text: 'Meesosfeerii (Mesosphere)', isCorrect: false),
          Option(text: 'Teermosfeerii (Thermosphere)', isCorrect: false),
        ],
      ),
      Question(
        id: 302,
        subjectId: 'hawaasummaa',
        text: 'Sirni Gadaa Oromoo waggaa meeqa meeqaan aangoo daddabarsa?',
        explanation: 'Sirni Gadaa waggaa 8(saddeet) saddeetiin aangoo nagaan walharkaa fuudha.',
        options: [
          Option(text: 'Waggaa 4', isCorrect: false),
          Option(text: 'Waggaa 5', isCorrect: false),
          Option(text: 'Waggaa 8', isCorrect: true),
          Option(text: 'Waggaa 10', isCorrect: false),
        ],
      ),
    ];
  }

  /// Seed realistic past Grade 8 exam results demonstrating performance & score improvement over time
  void _seedSampleExamResultsIfEmpty() {
    if (_fallbackResultsCache.isNotEmpty) return;

    final now = DateTime.now();
    final sampleResults = [
      ExamResult(
        id: 1,
        subjectId: 'herrega',
        score: 5,
        totalQuestions: 5,
        timeTaken: 620, // 10 min 20 sec
        dateTaken: now.subtract(const Duration(hours: 4)),
        isSynced: false,
      ),
      ExamResult(
        id: 2,
        subjectId: 'afaan_oromoo',
        score: 4,
        totalQuestions: 4,
        timeTaken: 430,
        dateTaken: now.subtract(const Duration(days: 1, hours: 2)),
        isSynced: true,
      ),
      ExamResult(
        id: 3,
        subjectId: 'saayinsii_waliigalaa',
        score: 3,
        totalQuestions: 3,
        timeTaken: 360,
        dateTaken: now.subtract(const Duration(days: 2, hours: 5)),
        isSynced: true,
      ),
      ExamResult(
        id: 4,
        subjectId: 'herrega',
        score: 4,
        totalQuestions: 5,
        timeTaken: 750,
        dateTaken: now.subtract(const Duration(days: 4, hours: 1)),
        isSynced: true,
      ),
      ExamResult(
        id: 5,
        subjectId: 'hawaasummaa',
        score: 2,
        totalQuestions: 2,
        timeTaken: 220,
        dateTaken: now.subtract(const Duration(days: 5, hours: 3)),
        isSynced: true,
      ),
      ExamResult(
        id: 6,
        subjectId: 'afaan_oromoo',
        score: 3,
        totalQuestions: 4,
        timeTaken: 520,
        dateTaken: now.subtract(const Duration(days: 7, hours: 2)),
        isSynced: true,
      ),
      ExamResult(
        id: 7,
        subjectId: 'herrega',
        score: 3,
        totalQuestions: 5,
        timeTaken: 890,
        dateTaken: now.subtract(const Duration(days: 10, hours: 4)),
        isSynced: true,
      ),
      ExamResult(
        id: 8,
        subjectId: 'hawaasummaa',
        score: 1,
        totalQuestions: 2,
        timeTaken: 310,
        dateTaken: now.subtract(const Duration(days: 13, hours: 6)),
        isSynced: true,
      ),
    ];

    _fallbackResultsCache.addAll(sampleResults);
  }
}

/// Global Riverpod provider for ExamIsarService
final examIsarServiceProvider = Provider<IExamIsarService>((ref) {
  return ExamIsarService();
});
