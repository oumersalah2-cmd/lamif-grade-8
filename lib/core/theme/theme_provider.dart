import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported high-contrast academic theme modes for Grade 8 students
enum StudentThemeMode {
  light('light', 'Ifaa (Light)', 'Qayyabannoo guyyaa fi bakka ifaatti'),
  dark('dark', 'Dukkana (Dark)', 'Qayyabannoo halkan - ija hin dadhabsiisu'),
  system('system', 'Akka Bilbilaa', 'Bifa sirna bilbila keetii hordofa');

  final String key;
  final String titleOm;
  final String subtitleOm;

  const StudentThemeMode(this.key, this.titleOm, this.subtitleOm);

  static StudentThemeMode fromKey(String? key) {
    return StudentThemeMode.values.firstWhere(
      (m) => m.key == key,
      orElse: () => StudentThemeMode.system,
    );
  }
}

/// SharedPreferences key for theme storage
const String kThemeModeStorageKey = 'lamif_student_theme_mode';

/// High-contrast theme configuration provider
class ThemeModeNotifier extends StateNotifier<StudentThemeMode> {
  final SharedPreferences? _prefs;

  ThemeModeNotifier([this._prefs]) : super(StudentThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final savedKey = prefs.getString(kThemeModeStorageKey);
    state = StudentThemeMode.fromKey(savedKey);
  }

  Future<void> setThemeMode(StudentThemeMode mode) async {
    state = mode;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(kThemeModeStorageKey, mode.key);
  }

  Future<void> toggleLightDark(bool isCurrentlyDark) async {
    final newMode = isCurrentlyDark ? StudentThemeMode.light : StudentThemeMode.dark;
    await setThemeMode(newMode);
  }
}

/// Provider exposing the current theme mode state
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, StudentThemeMode>((ref) {
  return ThemeModeNotifier();
});

/// High-contrast Theme definitions ensuring WCAG AAA accessibility
class AppHighContrastTheme {
  // Light Theme (Daylight Study)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF15803D), // Deep Emerald Forest Green
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDCFCE7),
      onPrimaryContainer: Color(0xFF14532D),
      secondary: Color(0xFFB45309), // Amber Gold
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFEF3C7),
      onSecondaryContainer: Color(0xFF78350F),
      background: Color(0xFFF8FAFC),
      onBackground: Color(0xFF0F172A), // Slate 900 (Ultra High Contrast 15:1)
      surface: Colors.white,
      onSurface: Color(0xFF0F172A),
      surfaceVariant: Color(0xFFF1F5F9),
      onSurfaceVariant: Color(0xFF334155),
      outline: Color(0xFFCBD5E1),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 1,
      shape: RoundedCornerShape(18),
    ),
  );

  // Dark Theme (Night / Low Light Study)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4ADE80), // Luminous Mint Green
      onPrimary: Color(0xFF052E16),
      primaryContainer: Color(0xFF14532D),
      onPrimaryContainer: Color(0xFFDCFCE7),
      secondary: Color(0xFFFBBF24), // High Visibility Gold
      onSecondary: Color(0xFF451A03),
      secondaryContainer: Color(0xFF78350F),
      onSecondaryContainer: Color(0xFFFEF3C7),
      background: Color(0xFF090D12), // OLED Night Black
      onBackground: Color(0xFFF8FAFC), // Pure White High Contrast
      surface: Color(0xFF131923),
      onSurface: Color(0xFFF8FAFC),
      surfaceVariant: Color(0xFF1E2633),
      onSurfaceVariant: Color(0xFFCBD5E1),
      outline: Color(0xFF334155),
    ),
    scaffoldBackgroundColor: const Color(0xFF090D12),
    cardTheme: CardTheme(
      color: const Color(0xFF131923),
      elevation: 2,
      shape: RoundedCornerShape(18),
    ),
  );
}
