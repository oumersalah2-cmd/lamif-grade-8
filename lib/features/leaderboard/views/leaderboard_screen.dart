import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_entry.dart';
import '../providers/leaderboard_provider.dart';
import '../repositories/leaderboard_repository.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeScope = ref.watch(selectedLeaderboardScopeProvider);
    final rankingsAsync = ref.watch(leaderboardListProvider);
    final currentStudentAsync = ref.watch(currentStudentRankProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Sadarkaa Barattootaa (Leaderboard)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: const Color(0xFF1B6E32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Scope Selector Filter Bar
            _buildScopeSelector(context, ref, activeScope),

            // 2. Rankings Content
            Expanded(
              child: rankingsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1B6E32)),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Dogoggora sadarkaa buusuu: ${err.toString()}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                data: (entries) {
                  if (entries.isEmpty) {
                    return const Center(
                      child: Text(
                        'Ragaan sadarkaa hin argamne.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final topThree = entries.take(3).toList();
                  final restOfEntries = entries.skip(3).toList();

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(leaderboardListProvider);
                    },
                    color: const Color(0xFF1B6E32),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      children: [
                        // Podium Cards for Top 3
                        if (topThree.isNotEmpty)
                          _buildPodiumSection(context, topThree),

                        const SizedBox(height: 20),

                        const Text(
                          'Tarree Sadarkaa Barattootaa',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // List of rankings #4 and below
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: restOfEntries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final entry = restOfEntries[index];
                            return _buildRankRow(context, entry);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Sticky User Rank Card at bottom
      bottomNavigationBar: currentStudentAsync.when(
        data: (student) {
          if (student == null) return const SizedBox.shrink();
          return _buildStickyCurrentUserBar(context, student);
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildScopeSelector(
    BuildContext context,
    WidgetRef ref,
    LeaderboardScope activeScope,
  ) {
    return Container(
      color: const Color(0xFF1B6E32),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _buildScopeButton(
              ref: ref,
              scope: LeaderboardScope.regional,
              label: 'Naannoo (Region)',
              isSelected: activeScope == LeaderboardScope.regional,
            ),
            _buildScopeButton(
              ref: ref,
              scope: LeaderboardScope.zone,
              label: 'Godina (Zone)',
              isSelected: activeScope == LeaderboardScope.zone,
            ),
            _buildScopeButton(
              ref: ref,
              scope: LeaderboardScope.school,
              label: 'Mana Barumsaa',
              isSelected: activeScope == LeaderboardScope.school,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeButton({
    required WidgetRef ref,
    required LeaderboardScope scope,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedLeaderboardScopeProvider.notifier).state = scope;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.Center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF1B6E32) : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumSection(BuildContext context, List<LeaderboardEntry> topThree) {
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place
        if (second != null)
          Expanded(child: _buildPodiumColumn(second, 2, const Color(0xFF94A3B8), 110)),

        const SizedBox(width: 8),

        // 1st Place (Taller)
        if (first != null)
          Expanded(child: _buildPodiumColumn(first, 1, const Color(0xFFF59E0B), 135)),

        const SizedBox(width: 8),

        // 3rd Place
        if (third != null)
          Expanded(child: _buildPodiumColumn(third, 3, const Color(0xFFB45309), 95)),
      ],
    );
  }

  Widget _buildPodiumColumn(LeaderboardEntry entry, int rank, Color crownColor, double height) {
    return Column(
      children: [
        Icon(
          rank == 1 ? Icons.emoji_events : Icons.workspace_premium,
          color: crownColor,
          size: rank == 1 ? 28 : 22,
        ),
        const SizedBox(height: 4),
        Text(
          entry.fullName.split(' ').first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          '${entry.averageScore.toStringAsFixed(1)}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: crownColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                crownColor.withOpacity(0.2),
                crownColor.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: crownColor.withOpacity(0.4)),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: crownColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.totalExamsTaken} Qormaata',
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankRow(BuildContext context, LeaderboardEntry entry) {
    final isMe = entry.isCurrentUser;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFD4EDDA) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? const Color(0xFF16A34A) : Colors.grey.shade200,
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isMe ? const Color(0xFF155D27) : Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isMe ? const Color(0xFF155D27) : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Ati',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.schoolName} • ${entry.zoneName}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.averageScore.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1B6E32),
                ),
              ),
              Text(
                '${entry.totalExamsTaken} Qormaata',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyCurrentUserBar(BuildContext context, LeaderboardEntry student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B6E32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '#${student.rank}',
              style: const TextStyle(
                color: Color(0xFFFFD54F),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sadarkaa Kee (Your Standing)',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Text(
                  'Qabxii Giddu-galeessaa: ${student.averageScore.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Jabaadhu! 🔥',
              style: TextStyle(
                color: Color(0xFF1B6E32),
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
