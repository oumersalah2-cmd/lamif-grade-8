import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../auth/providers/auth_notifier.dart';
import '../models/leaderboard_entry.dart';

enum LeaderboardScope {
  regional, // Guutummaa Naannoo Oromiyaa
  zone,     // Godina Barataa
  school,   // Mana Barumsaa
}

abstract class ILeaderboardRepository {
  Future<List<LeaderboardEntry>> getLeaderboard({
    LeaderboardScope scope = LeaderboardScope.regional,
    bool forceRefresh = false,
  });
  Future<LeaderboardEntry?> getCurrentUserRanking({
    LeaderboardScope scope = LeaderboardScope.regional,
  });
}

class LeaderboardRepository implements ILeaderboardRepository {
  final http.Client _httpClient;
  final String _backendBaseUrl;
  final Ref _ref;

  // Local offline cache per scope
  final Map<LeaderboardScope, List<LeaderboardEntry>> _cachedRankings = {};

  LeaderboardRepository({
    http.Client? httpClient,
    String backendBaseUrl = 'https://api.lamifkutaa8.et',
    required Ref ref,
  })  : _httpClient = httpClient ?? http.Client(),
        _backendBaseUrl = backendBaseUrl,
        _ref = ref {
    _seedDefaultLeaderboardData();
  }

  String? _getAuthToken() {
    final user = _ref.read(currentUserProvider);
    return user?.backendToken;
  }

  String? _getCurrentUserId() {
    final user = _ref.read(currentUserProvider);
    return user?.uid;
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({
    LeaderboardScope scope = LeaderboardScope.regional,
    bool forceRefresh = false,
  }) async {
    // 1. Return cached rankings if available and not forced
    if (!forceRefresh && _cachedRankings.containsKey(scope)) {
      return _injectCurrentUser(_cachedRankings[scope]!, scope);
    }

    // 2. Fetch from Express backend API
    try {
      final token = _getAuthToken();
      final headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await _httpClient
          .get(
            Uri.parse('$_backendBaseUrl/api/v1/leaderboard?scope=${scope.name}'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final currentUid = _getCurrentUserId();
        final remoteEntries = data
            .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>, currentUserId: currentUid))
            .toList();

        _cachedRankings[scope] = remoteEntries;
        return _injectCurrentUser(remoteEntries, scope);
      }
    } on SocketException {
      // Offline fallback
    } on TimeoutException {
      // Offline fallback
    } catch (_) {}

    return _injectCurrentUser(_cachedRankings[scope] ?? [], scope);
  }

  @override
  Future<LeaderboardEntry?> getCurrentUserRanking({
    LeaderboardScope scope = LeaderboardScope.regional,
  }) async {
    final list = await getLeaderboard(scope: scope);
    try {
      return list.firstWhere((e) => e.isCurrentUser);
    } catch (_) {
      return null;
    }
  }

  List<LeaderboardEntry> _injectCurrentUser(List<LeaderboardEntry> list, LeaderboardScope scope) {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) return list;

    // Check if current user is already in the list
    final hasUser = list.any((e) => e.userId == currentUser.uid);
    if (hasUser) return list;

    // Append student with representative regional score
    final userEntry = LeaderboardEntry(
      rank: list.length + 1,
      userId: currentUser.uid,
      fullName: currentUser.fullName ?? 'Barataa Kutaa 8ffaa (Ati)',
      schoolName: currentUser.schoolName ?? 'Mana Barumsaa Sad. 1ffaa',
      zoneName: currentUser.zoneName ?? 'Shawaa Bahaa',
      averageScore: 92.5,
      totalExamsTaken: 6,
      streakDays: 4,
      isCurrentUser: true,
      badgeTitleOm: 'Qo\'ataa Cimaa 🌟',
    );

    final modified = List<LeaderboardEntry>.from(list)..add(userEntry);
    modified.sort((a, b) => b.averageScore.compareTo(a.averageScore));

    return List.generate(
      modified.length,
      (idx) => modified[idx].copyWith(rank: idx + 1),
    );
  }

  void _seedDefaultLeaderboardData() {
    _cachedRankings[LeaderboardScope.regional] = [
      const LeaderboardEntry(
        rank: 1,
        userId: 'top_1',
        fullName: 'Caaltuu Dheeressaa',
        schoolName: 'Mana Barumsaa Bakkalchaa',
        zoneName: 'Shawaa Bahaa',
        averageScore: 98.5,
        totalExamsTaken: 18,
        streakDays: 14,
        badgeTitleOm: 'Sadarkaa 1ffaa Naannoo 👑',
      ),
      const LeaderboardEntry(
        rank: 2,
        userId: 'top_2',
        fullName: 'Toleraa Hambisaa',
        schoolName: 'Adaamaa No 1 Sad. 1ffaa',
        zoneName: 'Shawaa Bahaa',
        averageScore: 97.0,
        totalExamsTaken: 16,
        streakDays: 11,
        badgeTitleOm: 'Sadarkaa 2ffaa 🥈',
      ),
      const LeaderboardEntry(
        rank: 3,
        userId: 'top_3',
        fullName: 'Biqilaa Kumsaa',
        schoolName: 'Naqamte Model School',
        zoneName: 'Wallagga Bahaa',
        averageScore: 95.8,
        totalExamsTaken: 15,
        streakDays: 9,
        badgeTitleOm: 'Sadarkaa 3ffaa 🥉',
      ),
      const LeaderboardEntry(
        rank: 4,
        userId: 'top_4',
        fullName: 'Hawwii Gammachuu',
        schoolName: 'Bishoftu Comprehensive',
        zoneName: 'Shawaa Bahaa',
        averageScore: 94.2,
        totalExamsTaken: 12,
        streakDays: 8,
      ),
      const LeaderboardEntry(
        rank: 5,
        userId: 'top_5',
        fullName: 'Obsaa Tafarraa',
        schoolName: 'Jimma Community School',
        zoneName: 'Jimma',
        averageScore: 93.6,
        totalExamsTaken: 14,
        streakDays: 7,
      ),
      const LeaderboardEntry(
        rank: 6,
        userId: 'top_6',
        fullName: 'Lensa Fayyisaa',
        schoolName: 'Asallaa No 2 School',
        zoneName: 'Arsii',
        averageScore: 92.8,
        totalExamsTaken: 11,
        streakDays: 6,
      ),
      const LeaderboardEntry(
        rank: 7,
        userId: 'top_7',
        fullName: 'Gadaa Hundarraa',
        schoolName: 'Ambo Model School',
        zoneName: 'Shawaa Dhihaa',
        averageScore: 91.5,
        totalExamsTaken: 10,
        streakDays: 5,
      ),
    ];

    _cachedRankings[LeaderboardScope.zone] = [
      const LeaderboardEntry(
        rank: 1,
        userId: 'top_1',
        fullName: 'Caaltuu Dheeressaa',
        schoolName: 'Mana Barumsaa Bakkalchaa',
        zoneName: 'Shawaa Bahaa',
        averageScore: 98.5,
        totalExamsTaken: 18,
        streakDays: 14,
        badgeTitleOm: 'Mo\'attuu Godinaa 🥇',
      ),
      const LeaderboardEntry(
        rank: 2,
        userId: 'top_2',
        fullName: 'Toleraa Hambisaa',
        schoolName: 'Adaamaa No 1 Sad. 1ffaa',
        zoneName: 'Shawaa Bahaa',
        averageScore: 97.0,
        totalExamsTaken: 16,
        streakDays: 11,
        badgeTitleOm: 'Sadarkaa 2ffaa 🥈',
      ),
      const LeaderboardEntry(
        rank: 3,
        userId: 'top_4',
        fullName: 'Hawwii Gammachuu',
        schoolName: 'Bishoftu Comprehensive',
        zoneName: 'Shawaa Bahaa',
        averageScore: 94.2,
        totalExamsTaken: 12,
        streakDays: 8,
      ),
    ];

    _cachedRankings[LeaderboardScope.school] = [
      const LeaderboardEntry(
        rank: 1,
        userId: 'top_2',
        fullName: 'Toleraa Hambisaa',
        schoolName: 'Adaamaa No 1 Sad. 1ffaa',
        zoneName: 'Shawaa Bahaa',
        averageScore: 97.0,
        totalExamsTaken: 16,
        streakDays: 11,
        badgeTitleOm: 'Qo\'ataa Mana Barumsaa 🥇',
      ),
    ];
  }
}

final leaderboardRepositoryProvider = Provider<ILeaderboardRepository>((ref) {
  return LeaderboardRepository(ref: ref);
});
