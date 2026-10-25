import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/student_track.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../views/phone_auth_screen.dart';
import '../views/track_selection_screen.dart';

import '../../performance_analysis/views/performance_analysis_screen.dart';

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
        path: '/onboarding/track-selection',
        name: 'track_selection',
        builder: (context, state) => const TrackSelectionScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const AcademicDashboardScreen(),
      ),
      GoRoute(
        path: '/performance-analysis',
        name: 'performance_analysis',
        builder: (context, state) => const PerformanceAnalysisScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isSelectingTrack = state.matchedLocation == '/onboarding/track-selection';

      // 1. If still loading initial session, do not redirect
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      // 2. Unauthenticated -> Send to Login
      if (authState is UnauthenticatedState || authState is AuthErrorState) {
        return isLoggingIn ? null : '/login';
      }

      // 3. Phone verified but not onboarded -> Send to Track Selection
      if (authState is OtpVerifiedState) {
        return isSelectingTrack ? null : '/onboarding/track-selection';
      }

      // 4. Authenticated & Onboarded -> Send to Dashboard
      if (authState is AuthenticatedState) {
        if (!authState.isOnboarded) {
          return isSelectingTrack ? null : '/onboarding/track-selection';
        }
        // If already onboarded and trying to access login/onboarding, route to dashboard
        if (isLoggingIn || isSelectingTrack) {
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Lamif Kutaa 8 - Fuula Jalqabaa',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Ba\'i (Sign Out)',
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Student Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0D47A1).withOpacity(0.25),
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
                            shape: RoundedCornerShape(8),
                          ),
                          child: const Text('Jijjiiri', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // Section: Standard Ministry Exam Modules (Conditionally shown if ministryEnabled)
              if (showMinistry) ...[
                Row(
                  mainAxisAlignment: MainContent.spaceBetween,
                  children: const [
                    Text(
                      'Qormaata Ministeeraa (Naannoo)',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Icon(Icons.school, color: Color(0xFF1B6E32), size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                _buildExamModuleCard(
                  title: 'Afaan Oromoo, Herrega fi Saayinsii',
                  subtitle: 'Barnoota 7n Qormaata Naannoo Kutaa 8ffaa',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF1B6E32),
                  badge: 'Ministeera',
                ),
                const SizedBox(height: 10),
                _buildExamModuleCard(
                  title: 'Shaakala Qormaata Darbee (2008 - 2016)',
                  subtitle: 'Qormaatawwan naannoo kanaan dura dhufan',
                  icon: Icons.history_edu_rounded,
                  color: const Color(0xFF0F3D3E),
                  badge: '8 Waggoota',
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
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.auto_awesome, color: Color(0xFF0D47A1), size: 20),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manneen Barumsaa Bultii Addaa Ifa Boruu (Special Boarding School)',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                _buildExamModuleCard(
                  title: 'Qormaata Seensa Ifa Boruu - Shaakala Addaa',
                  subtitle: 'Herrega addaa, Sammuu-Qara (Aptitude) & English',
                  icon: Icons.workspace_premium_rounded,
                  color: const Color(0xFF0D47A1),
                  badge: 'Ifa Boruu Special',
                ),
                const SizedBox(height: 10),
                _buildExamModuleCard(
                  title: 'Madaallii Dandeettii fi Mock Exam',
                  subtitle: 'Qormaata qophii dorgommii sadarkaa naannoo',
                  icon: Icons.analytics_outlined,
                  color: const Color(0xFF1E3A8A),
                  badge: 'Dorgommii',
                ),
                const SizedBox(height: 24),
              ],

              // Section: Performance Analytics & Trends
              Row(
                mainAxisAlignment: MainContent.spaceBetween,
                children: const [
                  Text(
                    'Xiinxala Qabxii (Performance Trends)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Icon(Icons.insights_rounded, color: Color(0xFF0D47A1), size: 20),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => context.push('/performance-analysis'),
                borderRadius: BorderRadius.circular(16),
                child: _buildExamModuleCard(
                  title: 'Adeemsa Qabxii Barnootaa (D3 Visuals)',
                  subtitle: 'Garaa-garummaa qabxii fi fooyya\'iinsa yeroo wajjin ilaali',
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF0D47A1),
                  badge: 'Xiinxala',
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}
