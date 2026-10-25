package com.example.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

private val DarkColorScheme = darkColorScheme(
  primary = OromiaGreenLight,
  onPrimary = Color.Black,
  primaryContainer = OromiaGreenDark,
  onPrimaryContainer = Color.White,
  secondary = OromiaGoldLight,
  onSecondary = Color.Black,
  secondaryContainer = OnOromiaGoldContainer,
  onSecondaryContainer = OromiaGoldContainer,
  tertiary = Color(0xFFEF4444),
  background = DarkBackground,
  onBackground = TextPrimaryDark,
  surface = DarkSurface,
  onSurface = TextPrimaryDark,
  surfaceVariant = DarkSurfaceVariant,
  onSurfaceVariant = TextSecondaryDark,
  outline = Color(0xFF475569)
)

private val LightColorScheme = lightColorScheme(
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
  outline = LightOutline
)

@Composable
fun MyApplicationTheme(
  darkTheme: Boolean = isSystemInDarkTheme(),
  dynamicColor: Boolean = false, // Keep branded educational green/gold scheme
  content: @Composable () -> Unit,
) {
  val colorScheme = when {
    dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
      val context = LocalContext.current
      if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
    }
    darkTheme -> DarkColorScheme
    else -> LightColorScheme
  }

  MaterialTheme(
    colorScheme = colorScheme,
    typography = Typography,
    content = content
  )
}
