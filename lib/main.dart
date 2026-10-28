import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/theme/theme_provider.dart';
import 'core/analytics/analytics_service.dart';
import 'features/auth/routes/auth_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final analyticsService = AnalyticsService();

  try {
    await Firebase.initializeApp();
    await analyticsService.initialize();

    // 1. Capture framework fatal errors
    FlutterError.onError = (errorDetails) {
      if (analyticsService.hasConsent) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      }
      FlutterError.presentError(errorDetails);
    };

    // 2. Capture uncaught asynchronous platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      if (analyticsService.hasConsent) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      return true;
    };
  } catch (e) {
    debugPrint('Firebase / Crashlytics initialization skipped or not configured: $e');
  }

  // Set system UI overlay style for academic aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: LamifKutaa8App(),
    ),
  );
}

/// Root Application Widget for Lamif Kutaa 8 Prep.
/// Implements offline-first reactive state management with Riverpod,
/// high-contrast academic themes (Afaan Oromoo), and GoRouter navigation.
class LamifKutaa8App extends ConsumerWidget {
  const LamifKutaa8App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final studentThemeMode = ref.watch(themeModeProvider);

    // Map StudentThemeMode to Flutter's ThemeMode
    final ThemeMode themeMode;
    switch (studentThemeMode) {
      case StudentThemeMode.light:
        themeMode = ThemeMode.light;
        break;
      case StudentThemeMode.dark:
        themeMode = ThemeMode.dark;
        break;
      case StudentThemeMode.system:
        themeMode = ThemeMode.system;
        break;
    }

    return MaterialApp.router(
      title: 'Lamif Kutaa 8 Prep',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppHighContrastTheme.lightTheme,
      darkTheme: AppHighContrastTheme.darkTheme,
      themeMode: themeMode,
    );
  }
}
