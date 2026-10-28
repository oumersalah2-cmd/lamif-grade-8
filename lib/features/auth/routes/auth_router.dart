import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../models/student_track.dart';
import '../models/payment_status.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../views/phone_auth_screen.dart';
import '../views/pin_login_screen.dart';
import '../views/track_selection_screen.dart';
import '../views/payment_verification_screen.dart';
import '../views/payment_pending_screen.dart';

import '../../performance_analysis/views/performance_analysis_screen.dart';
import '../../dashboard/views/main_navigation_shell.dart';
import '../../exams/views/exam_catalog_screen.dart';
import '../../exams/screens/exam_history_screen.dart';
import '../../exams/screens/exam_screen.dart';
import '../../study/views/study_notes_screen.dart';
import '../../schedule/views/schedule_screen.dart';
import '../../leaderboard/views/leaderboard_screen.dart';
import '../../search/views/search_screen.dart';
import '../../study/views/grade_calculator_screen.dart';
import '../../study/views/weak_topics_screen.dart';
import '../../settings/privacy_settings_dialog.dart';

/// Centralized GoRouter configuration integrating Authentication & Onboarding
final appRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth state to trigger reactive redirection
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: '/pin-login',
        name: 'pin_login',
        builder: (context, state) => const PinLoginScreen(),
      ),
      GoRoute(
        path: '/onboarding/track-selection',
        name: 'track_selection',
        builder: (context, state) => const TrackSelectionScreen(),
      ),
      GoRoute(
        path: '/payment-verification',
        name: 'payment_verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final track = extra?['track'] as StudentTrack? ?? StudentTrack.both;
          final name = extra?['name'] as String? ?? 'Barataa Kutaa 8ffaa';
          final phone = extra?['phone'] as String? ?? '+251';
          final zone = extra?['zone'] as String? ?? 'Shawaa Bahaa';
          final school = extra?['school'] as String?;
          return PaymentVerificationScreen(
            track: track,
            studentName: name,
            phoneNumber: phone,
            schoolZone: zone,
            schoolName: school,
          );
        },
      ),
      GoRoute(
        path: '/payment-pending',
        name: 'payment_pending',
        builder: (context, state) => const PaymentPendingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const MainNavigationShell(),
      ),
      GoRoute(
        path: '/exams',
        name: 'exams',
        builder: (context, state) => const ExamCatalogScreen(),
      ),
      GoRoute(
        path: '/exam-history',
        name: 'exam_history',
        builder: (context, state) => const ExamHistoryScreen(),
      ),
      GoRoute(
        path: '/study',
        name: 'study',
        builder: (context, state) => const StudyNotesScreen(),
      ),
      GoRoute(
        path: '/schedule',
        name: 'schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/performance-analysis',
        name: 'performance_analysis',
        builder: (context, state) => const PerformanceAnalysisScreen(),
      ),
      GoRoute(
        path: '/grade-calculator',
        name: 'grade_calculator',
        builder: (context, state) => const GradeCalculatorScreen(),
      ),
      GoRoute(
        path: '/weak-topics',
        name: 'weak_topics',
        builder: (context, state) => const WeakTopicsScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isPinLogin = state.matchedLocation == '/pin-login';
      final isSelectingTrack = state.matchedLocation == '/onboarding/track-selection';
      final isVerifyingPayment = state.matchedLocation == '/payment-verification';
      final isPaymentPending = state.matchedLocation == '/payment-pending';

      // 1. If still loading initial session, do not redirect
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      // 2. PIN required for daily offline unlock
      if (authState is AuthPinRequiredState) {
        return isPinLogin ? null : '/pin-login';
      }

      // 3. Unauthenticated -> Send to Login
      if (authState is UnauthenticatedState || authState is AuthErrorState) {
        return isLoggingIn ? null : '/login';
      }

      // 4. Phone verified but not onboarded -> Send to Track Selection
      if (authState is OtpVerifiedState) {
        return (isSelectingTrack || isVerifyingPayment) ? null : '/onboarding/track-selection';
      }

      // 5. Authenticated & Onboarded -> Check Payment Verification
      if (authState is AuthenticatedState) {
        if (!authState.isOnboarded) {
          return (isSelectingTrack || isVerifyingPayment) ? null : '/onboarding/track-selection';
        }

        final isPaidVerified = authState.user.paymentStatus == PaymentStatus.verified;

        // If NOT verified yet, lock them out of all main exam content!
        if (!isPaidVerified) {
          if (isVerifyingPayment || isPaymentPending) {
            return null; // allow staying on payment flow
          }
          return '/payment-pending'; // lock out and redirect
        }

        // If verified, prevent navigating back to login, pin-login, pending, or onboarding
        if (isLoggingIn || isPinLogin || isSelectingTrack || isVerifyingPayment || isPaymentPending) {
          return '/dashboard';
        }
      }

      return null;
    },
  );
});

/// Production-ready Academic Dashboard demonstrating dynamic module filtering
/// based on the student's chosen track (hiding/showing "Ifa Boru" exam modules).
class AcademicDashboardScreen extends ConsumerWidget {
  const AcademicDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final activeTrack = ref.watch(studentTrackProvider);
    final showIfaBoru = ref.watch(shouldShowIfaBoruProvider);
    final showMinistry = ref.watch(shouldShowMinistryProvider);
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lamif Kutaa 8 - Fuula Jalqabaa',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Barbaadi (Search)',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            tooltip: 'Bifa (Theme)',
            icon: Icon(
              currentThemeMode == StudentThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
            onPressed: () => _showThemeDialog(context, ref),
          ),
          IconButton(
            tooltip: 'Qindaa\'ina Dhuunfaa (Privacy)',
            icon: const Icon(Icons.privacy_tip_outlined),
            onPressed: () => PrivacySettingsDialog.show(context),
          ),
          IconButton(
            tooltip: 'Ba\'i (Sign Out)',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Student Profile Card
              _buildStudentHeaderCard(context, ref, user, activeTrack),

              const SizedBox(height: 20),

              // Quick Action Shortcuts Grid (4 tiles)
              _buildQuickShortcutsGrid(context, ref),

              const SizedBox(height: 24),

              // Section: Standard Ministry Exam Modules (Conditionally shown if ministryEnabled)
              if (showMinistry) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Qormaata Ministeeraa (Naannoo)',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20, color: Color(0xFF15803D)),
                      onPressed: () {
                        ref.read(navigationIndexProvider.notifier).state = 1;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildExamModuleCard(
                  title: 'Afaan Oromoo, Herrega fi Saayinsii',
                  subtitle: 'Barnoota 7n Qormaata Naannoo Kutaa 8ffaa',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF15803D),
                  badge: 'Ministeera',
                  onTap: () {
                    ref.read(navigationIndexProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: 10),
                _buildExamModuleCard(
                  title: 'Shaakala Qormaata Darbee (2008 - 2016)',
                  subtitle: 'Qormaatawwan naannoo kanaan dura dhufan',
                  icon: Icons.history_edu_rounded,
                  color: const Color(0xFF0F3D3E),
                  badge: '8 Waggoota',
                  onTap: () => context.push('/exam-history'),
                ),
                const SizedBox(height: 24),
              ],

              // Section: Special Ifa Boru Modules (DYNAMICALLY HIDDEN or SHOWN based on studentTrack)
              if (showIfaBoru) ...[
                Row(
                  children: const [
                    Text(
                      'Qormaata Seensa Ifa Boruu',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.auto_awesome, color: Color(0xFF0D47A1), size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manneen Barumsaa Bultii Addaa Ifa Boruu (Special Boarding School)',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                _buildExamModuleCard(
                  title: 'Qormaata Seensa Ifa Boruu - Shaakala Addaa',
                  subtitle: 'Herrega addaa, Sammuu-Qara (Aptitude) & English',
                  icon: Icons.workspace_premium_rounded,
                  color: const Color(0xFF0D47A1),
                  badge: 'Ifa Boruu Special',
                  onTap: () {
                    ref.read(navigationIndexProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: 10),
                _buildExamModuleCard(
                  title: 'Madaallii Dandeettii fi Mock Exam',
                  subtitle: 'Qormaata qophii dorgommii sadarkaa naannoo',
                  icon: Icons.analytics_outlined,
                  color: const Color(0xFF1E3A8A),
                  badge: 'Dorgommii',
                  onTap: () {
                    ref.read(navigationIndexProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Section: Performance Analytics & Trends
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Xiinxala Qabxii (Performance Trends)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20, color: Color(0xFF0D47A1)),
                    onPressed: () => context.push('/performance-analysis'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildExamModuleCard(
                title: 'Adeemsa Qabxii Barnootaa (D3 Visuals)',
                subtitle: 'Garaa-garummaa qabxii fi fooyya\'iinsa yeroo wajjin ilaali',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF0D47A1),
                badge: 'Xiinxala',
                onTap: () => context.push('/performance-analysis'),
              ),

              const SizedBox(height: 24),

              // Section: Study Tools & Grade Calculator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Shallaggii fi Meeshaalee Qayyabannoo',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Grade calculation, target planner & weak-topic review',
                style: TextStyle(fontSize: 12.5, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              _buildExamModuleCard(
                title: 'Shallaggii Qabxii & Karoora (Grade Calculator)',
                subtitle: 'Giddu-galeessa herregi, karoora qabxii qopheeffadhu',
                icon: Icons.calculate_rounded,
                color: const Color(0xFF15803D),
                badge: 'Haaraa',
                onTap: () => context.push('/grade-calculator'),
              ),
              const SizedBox(height: 10),
              _buildExamModuleCard(
                title: 'Mata-dureewwan Dadhaboo (Weak Topics Quiz)',
                subtitle: 'Mata-dureewwan qabxii gadi-aanaa qaban adda baasiitii shaakali',
                icon: Icons.auto_graph_rounded,
                color: const Color(0xFFB45309),
                badge: 'Shaakala',
                onTap: () => context.push('/weak-topics'),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentHeaderCard(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    StudentTrack activeTrack,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15803D), Color(0xFF166534)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15803D).withOpacity(0.25),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Barataa Kutaa 8ffaa',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user?.schoolName ?? "Mana Barumsaa"} • ${user?.zoneName ?? "Oromiyaa"}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.verified, color: Color(0xFF4ADE80), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sagantaa: ${activeTrack.titleOm}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/onboarding/track-selection'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  backgroundColor: Colors.white12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Jijjiiri', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickShortcutsGrid(BuildContext context, WidgetRef ref) {
    final shortcuts = [
      {
        'title': 'Qormaata',
        'subtitle': 'Shaakala Guutuu',
        'icon': Icons.quiz_rounded,
        'color': const Color(0xFF15803D),
        'action': () => ref.read(navigationIndexProvider.notifier).state = 1,
      },
      {
        'title': 'Qayyabannoo',
        'subtitle': 'Yaadannoo & Seera',
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF0D47A1),
        'action': () => ref.read(navigationIndexProvider.notifier).state = 2,
      },
      {
        'title': 'Sagantaa',
        'subtitle': 'Karoora Guyyaa',
        'icon': Icons.calendar_month_rounded,
        'color': const Color(0xFFB45309),
        'action': () => ref.read(navigationIndexProvider.notifier).state = 3,
      },
      {
        'title': 'Sadarkaa',
        'subtitle': 'Ragaan Dorgommii',
        'icon': Icons.emoji_events_rounded,
        'color': const Color(0xFF7C3AED),
        'action': () => ref.read(navigationIndexProvider.notifier).state = 4,
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: shortcuts.length,
      itemBuilder: (context, index) {
        final item = shortcuts[index];
        final color = item['color'] as Color;

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: item['action'] as VoidCallback,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item['icon'] as IconData, color: color, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['subtitle'] as String,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badge,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bifa Filadhu (Theme)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: StudentThemeMode.values.map((mode) {
            return RadioListTile<StudentThemeMode>(
              title: Text(mode.titleOm),
              subtitle: Text(mode.subtitleOm, style: const TextStyle(fontSize: 12)),
              value: mode,
              groupValue: currentMode,
              activeColor: const Color(0xFF15803D),
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(val);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cufi'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ba\'uu Barbaaddaa?'),
        content: const Text('Appilikeeshinii keessaa ba\'uun gara fuula seensaa bilbilaatti deebi\'a.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Lakkii'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).signOut();
              context.go('/login');
            },
            child: const Text('Eeyyee, Ba\'i'),
          ),
        ],
      ),
    );
  }
}
