package com.example.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

// High-Contrast Dark Color Scheme for Students (Night/Dim Study)
private val HighContrastDarkColorScheme = darkColorScheme(
  primary = DarkGreenPrimary,
  onPrimary = Color(0xFF052E16),
  primaryContainer = DarkGreenContainer,
  onPrimaryContainer = OnDarkGreenContainer,
  secondary = DarkGold,
  onSecondary = Color(0xFF451A03),
  secondaryContainer = DarkGoldContainer,
  onSecondaryContainer = OnDarkGoldContainer,
  tertiary = Color(0xFFF87171),
  onTertiary = Color(0xFF450A0A),
  background = DarkBackground,
  onBackground = TextPrimaryDark,
  surface = DarkSurface,
  onSurface = TextPrimaryDark,
  surfaceVariant = DarkSurfaceVariant,
  onSurfaceVariant = TextSecondaryDark,
  outline = DarkOutline,
  outlineVariant = Color(0xFF1E293B)
)

// High-Contrast Light Color Scheme for Students (Daylight/Classroom)
private val HighContrastLightColorScheme = lightColorScheme(
  primary = OromiaGreenPrimary,
  onPrimary = Color.White,
  primaryContainer = OromiaGreenContainer,
  onPrimaryContainer = OnOromiaGreenContainer,
  secondary = OromiaGold,
  onSecondary = Color.White,
  secondaryContainer = OromiaGoldContainer,
  onSecondaryContainer = OnOromiaGoldContainer,
  tertiary = OromiaRed,
  onTertiary = Color.White,
  background = LightBackground,
  onBackground = TextPrimaryLight,
  surface = LightSurface,
  onSurface = TextPrimaryLight,
  surfaceVariant = LightSurfaceVariant,
  onSurfaceVariant = TextSecondaryLight,
  outline = LightOutline,
  outlineVariant = Color(0xFFE2E8F0)
)

/**
 * Custom application theme supporting light, dark, and system modes
 * with guaranteed high-contrast accessibility.
 */
@Composable
fun MyApplicationTheme(
  themeMode: AppThemeMode = AppThemeMode.SYSTEM,
  dynamicColor: Boolean = false,
  content: @Composable () -> Unit,
) {
  val systemIsDark = isSystemInDarkTheme()
  val darkTheme = when (themeMode) {
    AppThemeMode.SYSTEM -> systemIsDark
    AppThemeMode.LIGHT -> false
    AppThemeMode.DARK -> true
  }

  val colorScheme = when {
    dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
      val context = LocalContext.current
      if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
    }
    darkTheme -> HighContrastDarkColorScheme
    else -> HighContrastLightColorScheme
  }

  CompositionLocalProvider(
    LocalAppThemeMode provides themeMode
  ) {
    MaterialTheme(
      colorScheme = colorScheme,
      typography = Typography,
      content = content
    )
  }
}
