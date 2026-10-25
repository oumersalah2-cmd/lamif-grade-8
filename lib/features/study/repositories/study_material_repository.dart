import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../auth/providers/auth_notifier.dart';
import '../models/study_material_model.dart';
import '../models/subject_model.dart';

/// Abstract contract for Study Material Repository
abstract class IStudyMaterialRepository {
  Future<List<SubjectModel>> getSubjects({bool forceRefresh = false});
  Future<List<StudyMaterialModel>> getMaterialsBySubject(String subjectId, {bool forceRefresh = false});
  Future<List<StudyMaterialModel>> getAllMaterials();
  Future<List<StudyMaterialModel>> searchMaterials(String query, {String? subjectId});
  Future<bool> downloadSubjectForOffline(String subjectId);
  Future<void> saveLocalMaterial(StudyMaterialModel material);
}

/// Abstract contract for Local Storage (Isar Database abstraction)
abstract class ILocalStudyStorage {
  Future<List<SubjectModel>> getLocalSubjects();
  Future<void> saveSubjects(List<SubjectModel> subjects);
  Future<List<StudyMaterialModel>> getLocalMaterials(String subjectId);
  Future<List<StudyMaterialModel>> getAllLocalMaterials();
  Future<void> saveMaterials(List<StudyMaterialModel> materials);
  Future<void> markSubjectDownloaded(String subjectId);
}

/// In-Memory and persistent local store mimicking Isar collections
class LocalStudyStorage implements ILocalStudyStorage {
  final Map<String, SubjectModel> _subjects = {};
  final Map<String, List<StudyMaterialModel>> _materialsBySubject = {};

  LocalStudyStorage() {
    _seedDefaultData();
  }

  @override
  Future<List<SubjectModel>> getLocalSubjects() async {
    return _subjects.values.toList();
  }

  @override
  Future<void> saveSubjects(List<SubjectModel> subjects) async {
    for (final s in subjects) {
      _subjects[s.id] = s;
    }
  }

  @override
  Future<List<StudyMaterialModel>> getLocalMaterials(String subjectId) async {
    return _materialsBySubject[subjectId] ?? [];
  }

  @override
  Future<List<StudyMaterialModel>> getAllLocalMaterials() async {
    final all = <StudyMaterialModel>[];
    for (final list in _materialsBySubject.values) {
      all.addAll(list);
    }
    return all;
  }

  @override
  Future<void> saveMaterials(List<StudyMaterialModel> materials) async {
    for (final m in materials) {
      _materialsBySubject.putIfAbsent(m.subjectId, () => []);
      final list = _materialsBySubject[m.subjectId]!;
      list.removeWhere((item) => item.id == m.id);
      list.add(m);
    }
  }

  @override
  Future<void> markSubjectDownloaded(String subjectId) async {
    final existing = _subjects[subjectId];
    if (existing != null) {
      _subjects[subjectId] = existing.copyWith(isDownloadedForOffline: true);
    }
  }

  void _seedDefaultData() {
    final defaultSubjects = [
      const SubjectModel(
        id: 'afaan_oromoo',
        nameOm: 'Afaan Oromoo',
        nameEn: 'Afaan Oromoo',
        descriptionOm: 'Caasluga, Dhamjecha, Mamaksa fi Og-barruu',
        iconName: 'menu_book',
        accentColorHex: '#16A34A',
        totalUnits: 6,
        totalQuestionsCount: 40,
        isDownloadedForOffline: true,
      ),
      const SubjectModel(
        id: 'herrega',
        nameOm: 'Herrega',
        nameEn: 'Mathematics',
        descriptionOm: 'Lakkofsoota, Aljebraa, Ji\'oomeetirii fi Pisii',
        iconName: 'calculate',
        accentColorHex: '#2563EB',
        totalUnits: 7,
        totalQuestionsCount: 45,
        isDownloadedForOffline: true,
      ),
      const SubjectModel(
        id: 'saayinsii_waliigalaa',
        nameOm: 'Saayinsii Waliigalaa',
        nameEn: 'General Science',
        descriptionOm: 'Baayoloojii, Fiiziksii fi Keemistirii',
        iconName: 'science',
        accentColorHex: '#7C3AED',
        totalUnits: 8,
        totalQuestionsCount: 50,
        isDownloadedForOffline: true,
      ),
      const SubjectModel(
        id: 'saayinsii_hawaasaa',
        nameOm: 'Saayinsii Hawaasaa',
        nameEn: 'Social Studies',
        descriptionOm: 'Seenaa, Ji\'oogiraafii fi Hawaasummaa',
        iconName: 'public',
        accentColorHex: '#EA580C',
        totalUnits: 6,
        totalQuestionsCount: 35,
        isDownloadedForOffline: true,
      ),
      const SubjectModel(
        id: 'lammummaa',
        nameOm: 'Barnoota Lammummaa',
        nameEn: 'Citizenship',
        descriptionOm: 'Heera, Dimokraasii, Mirga fi Dirqama',
        iconName: 'gavel',
        accentColorHex: '#0D9488',
        totalUnits: 5,
        totalQuestionsCount: 30,
        isDownloadedForOffline: true,
      ),
      const SubjectModel(
        id: 'english',
        nameOm: 'Afaan Ingilizii',
        nameEn: 'English Language',
        descriptionOm: 'Grammar, Vocabulary & Comprehension',
        iconName: 'language',
        accentColorHex: '#D97706',
        totalUnits: 6,
        totalQuestionsCount: 40,
        isDownloadedForOffline: true,
      ),
    ];

    for (final s in defaultSubjects) {
      _subjects[s.id] = s;
    }

    _materialsBySubject['herrega'] = [
      StudyMaterialModel(
        id: 'mat_math_pythagoras',
        subjectId: 'herrega',
        unitNumber: 4,
        unitTitleOm: "Boqonnaa 4: Ji'oomeetirii fi Rog-sadee",
        topicTitleOm: "Tiwooremii Paayitaagorasii",
        summaryContentOm: "Rog-sadee kofa sirrii (90°) qabu keessatti rogi dheeraan kofa sirriitti fuulleffatu haayipootinasii (c) jedhama. C² = a² + b².",
        keyFormulasOrRules: [
          "c² = a² + b²",
          "c = √(a² + b²)",
          "a² = c² - b²",
        ],
        pastExamTipsOm: "Qormaata Ministry keessatti yeroo hunda cimdiin (3, 4, 5) fi (6, 8, 10) irra deddeebiin gaafatamu.",
        updatedAt: DateTime.now(),
      ),
      StudyMaterialModel(
        id: 'mat_math_area',
        subjectId: 'herrega',
        unitNumber: 5,
        unitTitleOm: "Boqonnaa 5: Bal'ina fi Marsee",
        topicTitleOm: "Bal'ina Geengoo fi Rog-baay'ee",
        summaryContentOm: "Bal'inni geengoo A = πr² yoo ta'u, marseen (circumference) C = 2πr dha. Bal'inni rog-sadee A = 1/2 × b × h dha.",
        keyFormulasOrRules: [
          "Bal'ina Geengoo: A = πr² (π ≈ 3.14)",
          "Marsee Geengoo: C = 2πr",
          "Bal'ina Rog-sadee: A = 1/2 × b × h",
        ],
        pastExamTipsOm: "Raadiyasiifi diyaameetirii walitti makuu irraa of eeggadhaa; d = 2r.",
        updatedAt: DateTime.now(),
      ),
    ];

    _materialsBySubject['saayinsii_waliigalaa'] = [
      StudyMaterialModel(
        id: 'mat_sci_cell',
        subjectId: 'saayinsii_waliigalaa',
        unitNumber: 2,
        unitTitleOm: "Boqonnaa 2: Lubbiyyoo fi Seelii",
        topicTitleOm: "Caasaalee Seelii fi Hojii Isaanii",
        summaryContentOm: "Seeliin bu'uura lubbu qabeeyyiiti. Maaytookondiriyaan annisaa (ATP) maddisiisa, Kilooropilaastiin immoo footoosinteesisii gaggeessa.",
        keyFormulasOrRules: [
          "Maaytookondiriyaa: Mooraa Annisaa (Powerhouse)",
          "Niwukilasii: Wiirtuu to'annoo seelii",
          "Kilooropilaastii: Footoosinteesisiif barbaachisa (Biqiltoota qofa)",
        ],
        pastExamTipsOm: "Garaagarummaa seelii biqiltootaafi bineensotaa (cell wall & chloroplast) irratti xiyyeeffadhaa.",
        updatedAt: DateTime.now(),
      ),
    ];

    _materialsBySubject['afaan_oromoo'] = [
      StudyMaterialModel(
        id: 'mat_ao_dhamjecha',
        subjectId: 'afaan_oromoo',
        unitNumber: 1,
        unitTitleOm: "Boqonnaa 1: Caasluga Afaan Oromoo",
        topicTitleOm: "Dhamjecha Walabaa fi Hirkataa",
        summaryContentOm: "Dhamjechi kutaa xiqqaa jechaa hiika qabudha. Dhamjecha walabaa of danda'ee hiika qaba; dhamjechi hirkataan immoo dhamjecha biraatti maxxana.",
        keyFormulasOrRules: [
          "Dhamjecha Walaba: Mana, Nam, Barrees",
          "Dhamjecha Hirkataa: -oota, -e, -dhaan, -ummaa",
        ],
        pastExamTipsOm: "Dhamjecha uumaa fi dhamjecha hortee gargar baasanii beekuun baay'ee murteessaadha.",
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

/// Production implementation of IStudyMaterialRepository
class StudyMaterialRepository implements IStudyMaterialRepository {
  final ILocalStudyStorage _localStorage;
  final http.Client _httpClient;
  final String _backendBaseUrl;
  final Ref _ref;

  StudyMaterialRepository({
    required ILocalStudyStorage localStorage,
    http.Client? httpClient,
    String backendBaseUrl = 'https://api.lamifkutaa8.et',
    required Ref ref,
  })  : _localStorage = localStorage,
        _httpClient = httpClient ?? http.Client(),
        _backendBaseUrl = backendBaseUrl,
        _ref = ref;

  String? _getAuthToken() {
    final user = _ref.read(currentUserProvider);
    return user?.backendToken;
  }

  @override
  Future<List<SubjectModel>> getSubjects({bool forceRefresh = false}) async {
    final localSubjects = await _localStorage.getLocalSubjects();
    if (localSubjects.isNotEmpty && !forceRefresh) {
      return localSubjects;
    }

    try {
      final token = _getAuthToken();
      final headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await _httpClient
          .get(Uri.parse('$_backendBaseUrl/api/v1/subjects'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final remote = data.map((e) => SubjectModel.fromJson(e as Map<String, dynamic>)).toList();
        await _localStorage.saveSubjects(remote);
        return remote;
      }
    } on SocketException {
      // Offline fallback
    } on TimeoutException {
      // Offline fallback
    } catch (_) {}

    return localSubjects;
  }

  @override
  Future<List<StudyMaterialModel>> getMaterialsBySubject(String subjectId, {bool forceRefresh = false}) async {
    // 1. Return offline cached materials immediately
    final localMaterials = await _localStorage.getLocalMaterials(subjectId);
    if (localMaterials.isNotEmpty && !forceRefresh) {
      return localMaterials;
    }

    // 2. Fetch fresh materials from remote backend when online
    try {
      final token = _getAuthToken();
      final headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await _httpClient
          .get(Uri.parse('$_backendBaseUrl/api/v1/subjects/$subjectId/materials'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final remote = data.map((e) => StudyMaterialModel.fromJson(e as Map<String, dynamic>)).toList();
        await _localStorage.saveMaterials(remote);
        return remote;
      }
    } on SocketException {
      // Offline
    } on TimeoutException {
      // Timeout
    } catch (_) {}

    return localMaterials;
  }

  @override
  Future<bool> downloadSubjectForOffline(String subjectId) async {
    final materials = await getMaterialsBySubject(subjectId, forceRefresh: true);
    if (materials.isNotEmpty) {
      await _localStorage.markSubjectDownloaded(subjectId);
      return true;
    }
    return false;
  }

  @override
  Future<List<StudyMaterialModel>> getAllMaterials() async {
    return await _localStorage.getAllLocalMaterials();
  }

  @override
  Future<List<StudyMaterialModel>> searchMaterials(String query, {String? subjectId}) async {
    final lowerQ = query.trim().toLowerCase();
    final all = await getAllMaterials();
    return all.where((m) {
      if (subjectId != null && subjectId.isNotEmpty && m.subjectId.toLowerCase() != subjectId.toLowerCase()) {
        return false;
      }
      if (lowerQ.isEmpty) return true;
      final topicMatch = m.topicTitleOm.toLowerCase().contains(lowerQ);
      final unitMatch = m.unitTitleOm.toLowerCase().contains(lowerQ);
      final summaryMatch = m.summaryContentOm.toLowerCase().contains(lowerQ);
      final tipsMatch = m.pastExamTipsOm.toLowerCase().contains(lowerQ);
      final formulasMatch = m.keyFormulasOrRules.any((f) => f.toLowerCase().contains(lowerQ));
      return topicMatch || unitMatch || summaryMatch || tipsMatch || formulasMatch;
    }).toList();
  }

  @override
  Future<void> saveLocalMaterial(StudyMaterialModel material) async {
    await _localStorage.saveMaterials([material]);
  }
}

// ================= Riverpod Providers =================

final localStudyStorageProvider = Provider<ILocalStudyStorage>((ref) {
  return LocalStudyStorage();
});

final studyMaterialRepositoryProvider = Provider<IStudyMaterialRepository>((ref) {
  final localStorage = ref.watch(localStudyStorageProvider);
  return StudyMaterialRepository(
    localStorage: localStorage,
    ref: ref,
  );
});

final subjectsListProvider = FutureProvider<List<SubjectModel>>((ref) async {
  final repo = ref.watch(studyMaterialRepositoryProvider);
  return repo.getSubjects();
});

final materialsBySubjectProvider = FutureProvider.family<List<StudyMaterialModel>, String>((ref, subjectId) async {
  final repo = ref.watch(studyMaterialRepositoryProvider);
  return repo.getMaterialsBySubject(subjectId);
});
