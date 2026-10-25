package com.example.ui.theme

import android.content.Context
import android.content.SharedPreferences
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BrightnessAuto
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.ui.graphics.vector.ImageVector
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * High-contrast theme modes designed for Grade 8 student readability
 */
enum class AppThemeMode(
  val storageKey: String,
  val titleOm: String,
  val subtitleOm: String,
  val icon: ImageVector
) {
  LIGHT(
    storageKey = "LIGHT",
    titleOm = "Ifaa (Light)",
    subtitleOm = "Qayyabannoo guyyaa fi bakka ifaatti",
    icon = Icons.Default.LightMode
  ),
  DARK(
    storageKey = "DARK",
    titleOm = "Dukkana (Dark)",
    subtitleOm = "Qayyabannoo halkan - ija hin dadhabsiisu",
    icon = Icons.Default.DarkMode
  ),
  SYSTEM(
    storageKey = "SYSTEM",
    titleOm = "Akka Bilbilaa (System)",
    subtitleOm = "Bifa sirna bilbila keetii hordofa",
    icon = Icons.Default.BrightnessAuto
  );

  companion object {
    fun fromKey(key: String?): AppThemeMode {
      return entries.find { it.storageKey == key } ?: SYSTEM
    }
  }
}

/**
 * Singleton theme manager providing reactive theme mode state
 * persisted securely in SharedPreferences.
 */
class AppThemeManager private constructor(context: Context) {

  private val prefs: SharedPreferences = context.applicationContext.getSharedPreferences(
    PREFS_NAME,
    Context.MODE_PRIVATE
  )

  private val _themeMode = MutableStateFlow(loadInitialThemeMode())
  val themeMode: StateFlow<AppThemeMode> = _themeMode.asStateFlow()

  private fun loadInitialThemeMode(): AppThemeMode {
    val savedKey = prefs.getString(KEY_THEME_MODE, AppThemeMode.SYSTEM.storageKey)
    return AppThemeMode.fromKey(savedKey)
  }

  fun setThemeMode(mode: AppThemeMode) {
    _themeMode.value = mode
    prefs.edit().putString(KEY_THEME_MODE, mode.storageKey).apply()
  }

  /**
   * Fast toggle between Light and Dark mode for quick-action button in TopAppBar
   */
  fun toggleLightDark(currentlyDark: Boolean) {
    val newMode = if (currentlyDark) AppThemeMode.LIGHT else AppThemeMode.DARK
    setThemeMode(newMode)
  }

  companion object {
    private const val PREFS_NAME = "lamif_app_theme_prefs"
    private const val KEY_THEME_MODE = "app_theme_mode"

    @Volatile
    private var INSTANCE: AppThemeManager? = null

    fun getInstance(context: Context): AppThemeManager {
      return INSTANCE ?: synchronized(this) {
        INSTANCE ?: AppThemeManager(context).also { INSTANCE = it }
      }
    }
  }
}

val LocalAppThemeMode = compositionLocalOf { AppThemeMode.SYSTEM }
