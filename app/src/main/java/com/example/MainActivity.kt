package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
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
import com.example.features.study.StudyNotesScreen
import com.example.ui.theme.MyApplicationTheme

enum class AppScreen {
  HOME,
  EXAM,
  RESULT,
  STUDY_NOTES,
  PROFILE
}

class MainActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    enableEdgeToEdge()
    setContent {
      MyApplicationTheme {
        Surface(
          modifier = Modifier.fillMaxSize(),
          color = MaterialTheme.colorScheme.background
        ) {
          LamifKutaa8App()
        }
      }
    }
  }
}

@Composable
fun LamifKutaa8App() {
  var currentScreen by remember { mutableStateOf(AppScreen.HOME) }
  val homeViewModel: HomeViewModel = viewModel()
  val examViewModel: ExamViewModel = viewModel()
  val authViewModel: AuthViewModel = viewModel()

  var lastSubject by remember { mutableStateOf(Subject.AFAAN_OROMOO) }
  var lastMode by remember { mutableStateOf(ExamMode.MOCK_MINISTRY) }

  when (currentScreen) {
    AppScreen.HOME -> {
      HomeScreen(
        viewModel = homeViewModel,
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

    AppScreen.PROFILE -> {
      BackHandler {
        currentScreen = AppScreen.HOME
      }
      ProfileScreen(
        viewModel = authViewModel,
        onNavigateBack = {
          currentScreen = AppScreen.HOME
        }
      )
    }
  }
}
