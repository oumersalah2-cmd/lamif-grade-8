import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_entry.dart';
import '../repositories/leaderboard_repository.dart';

/// Currently selected leaderboard filter scope
final selectedLeaderboardScopeProvider = StateProvider<LeaderboardScope>((ref) {
  return LeaderboardScope.regional;
});

/// Fetches ranked student entries for the currently selected scope
final leaderboardListProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final scope = ref.watch(selectedLeaderboardScopeProvider);
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.getLeaderboard(scope: scope);
});

/// Retrieves the current student's rank entry for the active scope
final currentStudentRankProvider = FutureProvider<LeaderboardEntry?>((ref) async {
  final scope = ref.watch(selectedLeaderboardScopeProvider);
  final repository = ref.watch(leaderboardRepositoryProvider);
  return repository.getCurrentUserRanking(scope: scope);
});
