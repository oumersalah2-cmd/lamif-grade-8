package com.example

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.data.model.Subject
import com.example.features.auth.AuthViewModel
import com.example.features.auth.ProfileScreen
import com.example.features.exams.ExamMode
import com.example.features.exams.ExamScreen
import com.example.features.exams.ExamViewModel
import com.example.features.home.HomeScreen
import com.example.features.home.HomeViewModel
import com.example.features.results.ExamResultScreen
import com.example.features.schedule.ScheduleScreen
import com.example.features.schedule.ScheduleViewModel
import com.example.features.study.StudyNotesScreen
import com.example.data.sync.ExamSyncManager
import com.example.ui.theme.MyApplicationTheme

enum class AppScreen {
  HOME,
  EXAM,
  RESULT,
  STUDY_NOTES,
  SCHEDULE,
  PROFILE
}

class MainActivity : ComponentActivity() {
  private var initialScreen = AppScreen.HOME

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    enableEdgeToEdge()
    // Initialize WorkManager background sync service monitoring network availability
    ExamSyncManager.schedulePeriodicSync(applicationContext)

    // Check if launched from study reminder notification
    if (intent?.getStringExtra(com.example.features.schedule.notifications.StudyNotificationHelper.EXTRA_OPEN_SCREEN) ==
      com.example.features.schedule.notifications.StudyNotificationHelper.SCREEN_SCHEDULE
    ) {
      initialScreen = AppScreen.SCHEDULE
    }

    val themeManager = com.example.ui.theme.AppThemeManager.getInstance(applicationContext)

    setContent {
      val themeMode by themeManager.themeMode.collectAsState()
      MyApplicationTheme(themeMode = themeMode) {
        Surface(
          modifier = Modifier.fillMaxSize(),
          color = MaterialTheme.colorScheme.background
        ) {
          val isSystemDark = androidx.compose.foundation.isSystemInDarkTheme()
          LamifKutaa8App(
            startingScreen = initialScreen,
            themeMode = themeMode,
            onThemeModeChanged = { themeManager.setThemeMode(it) },
            onQuickToggleTheme = {
              val isCurrentlyDark = when (themeMode) {
                com.example.ui.theme.AppThemeMode.SYSTEM -> isSystemDark
                com.example.ui.theme.AppThemeMode.DARK -> true
                com.example.ui.theme.AppThemeMode.LIGHT -> false
                else -> isSystemDark
              }
              themeManager.toggleLightDark(isCurrentlyDark)
            }
          )
        }
      }
    }
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
  }
}

@Composable
fun LamifKutaa8App(
  startingScreen: AppScreen = AppScreen.HOME,
  themeMode: com.example.ui.theme.AppThemeMode = com.example.ui.theme.AppThemeMode.SYSTEM,
  onThemeModeChanged: (com.example.ui.theme.AppThemeMode) -> Unit = {},
  onQuickToggleTheme: () -> Unit = {}
) {
  var currentScreen by remember { mutableStateOf(startingScreen) }
  val homeViewModel: HomeViewModel = viewModel()
  val examViewModel: ExamViewModel = viewModel()
  val authViewModel: AuthViewModel = viewModel()
  val scheduleViewModel: ScheduleViewModel = viewModel()

  var lastSubject by remember { mutableStateOf(Subject.AFAAN_OROMOO) }
  var lastMode by remember { mutableStateOf(ExamMode.MOCK_MINISTRY) }

  when (currentScreen) {
    AppScreen.HOME -> {
      HomeScreen(
        viewModel = homeViewModel,
        themeMode = themeMode,
        onQuickToggleTheme = onQuickToggleTheme,
        onStartExam = { subject, mode ->
          lastSubject = subject
          lastMode = mode
          examViewModel.startExam(subject, mode)
          currentScreen = AppScreen.EXAM
        },
        onOpenStudyNotes = { currentScreen = AppScreen.STUDY_NOTES },
        onOpenProfile = { currentScreen = AppScreen.PROFILE },
        onReviewMistakes = {
          examViewModel.startMistakesExam()
          currentScreen = AppScreen.EXAM
        },
        onOpenSchedule = {
          currentScreen = AppScreen.SCHEDULE
        }
      )
    }

    AppScreen.EXAM -> {
      ExamScreen(
        viewModel = examViewModel,
        onExamFinished = {
          currentScreen = AppScreen.RESULT
        },
        onNavigateBack = {
          currentScreen = AppScreen.HOME
        }
      )
    }

    AppScreen.RESULT -> {
      BackHandler {
        currentScreen = AppScreen.HOME
      }
      ExamResultScreen(
        viewModel = examViewModel,
        onRetakeExam = {
          examViewModel.startExam(lastSubject, lastMode)
          currentScreen = AppScreen.EXAM
        },
        onGoHome = {
          currentScreen = AppScreen.HOME
        }
      )
    }

    AppScreen.STUDY_NOTES -> {
      BackHandler {
        currentScreen = AppScreen.HOME
      }
      StudyNotesScreen(
        onNavigateBack = {
          currentScreen = AppScreen.HOME
        }
      )
    }

    AppScreen.SCHEDULE -> {
      BackHandler {
        currentScreen = AppScreen.HOME
      }
      ScheduleScreen(
        viewModel = scheduleViewModel,
        onNavigateBack = {
          currentScreen = AppScreen.HOME
        }
      )
    }

    AppScreen.PROFILE -> {
      BackHandler {
        currentScreen = AppScreen.HOME
      }
      ProfileScreen(
        viewModel = authViewModel,
        themeMode = themeMode,
        onThemeModeChanged = onThemeModeChanged,
        onNavigateBack = {
          currentScreen = AppScreen.HOME
        }
      )
    }
  }
}
