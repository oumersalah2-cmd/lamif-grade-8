import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/routes/auth_router.dart';
import '../../exams/views/exam_catalog_screen.dart';
import '../../study/views/study_notes_screen.dart';
import '../../schedule/views/schedule_screen.dart';
import '../../leaderboard/views/leaderboard_screen.dart';

/// State provider for active bottom navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Main persistent navigation shell housing the 5 core tabs of Lamif Kutaa 8 Prep:
/// 1. Daashboordii (Home & Profile)
/// 2. Qormaata (Exams Catalog)
/// 3. Qayyabannoo (Study Notes & Formulas)
/// 4. Sagantaa (Study Planner & Daily Schedule)
/// 5. Sadarkaa (Leaderboard Rankings)
class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(navigationIndexProvider);

    final pages = const [
      AcademicDashboardScreen(),
      ExamCatalogScreen(),
      StudyNotesScreen(),
      ScheduleScreen(),
      LeaderboardScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: activeIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: activeIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        backgroundColor: Theme.of(context).cardColor,
        elevation: 3,
        indicatorColor: const Color(0xFF15803D).withOpacity(0.18),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF15803D)),
            label: 'Mana',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz_rounded, color: Color(0xFF15803D)),
            label: 'Qormaata',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded, color: Color(0xFF15803D)),
            label: 'Qayyabannoo',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded, color: Color(0xFF15803D)),
            label: 'Sagantaa',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded, color: Color(0xFF15803D)),
            label: 'Sadarkaa',
          ),
        ],
      ),
    );
  }
}
