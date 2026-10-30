package com.example.features.exams

import android.app.Application
import android.os.SystemClock
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.local.AppDatabase
import com.example.data.local.entities.ExamAttemptEntity
import com.example.data.local.entities.QuestionEntity
import com.example.data.model.Subject
import com.example.data.repository.ExamRepository
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.util.UUID

enum class ExamMode {
  MOCK_MINISTRY, // Timed, no instant answers, realistic exam
  PRACTICE       // Untimed or casual, instant answer feedback & explanations
}

data class ExamUiState(
  val subject: Subject = Subject.AFAAN_OROMOO,
  val mode: ExamMode = ExamMode.MOCK_MINISTRY,
  val questions: List<QuestionEntity> = emptyList(),
  val currentQuestionIndex: Int = 0,
  val selectedAnswers: Map<String, Int> = emptyMap(), // questionId -> optionIndex
  val flaggedQuestions: Set<String> = emptySet(),
  val bookmarkedQuestions: Set<String> = emptySet(),
  val remainingSeconds: Long = 1800, // 30 minutes
  val totalExamSeconds: Long = 1800,
  val isFinished: Boolean = false,
  val isPaused: Boolean = false,
  val isTimeUp: Boolean = false,
  val showExplanation: Boolean = false,
  val completedAttempt: ExamAttemptEntity? = null
)

class ExamViewModel(application: Application) : AndroidViewModel(application) {
  private val repository = ExamRepository(AppDatabase.getDatabase(application), application)

  private val _uiState = MutableStateFlow(ExamUiState())
  val uiState: StateFlow<ExamUiState> = _uiState.asStateFlow()

  private var timerJob: Job? = null
  private var examEndTimeMillis: Long = 0L

  init {
    viewModelScope.launch {
      repository.getAllBookmarks().collect { bookmarks ->
        val bookmarkedIds = bookmarks.map { it.questionId }.toSet()
        _uiState.update { it.copy(bookmarkedQuestions = bookmarkedIds) }
      }
    }
  }

  fun startExam(subject: Subject, mode: ExamMode, customMinutes: Int? = null) {
    viewModelScope.launch {
      val loadedQuestions = repository.getQuestionsForSubjectDirect(subject.id).shuffled()
      val questions = if (loadedQuestions.isNotEmpty()) loadedQuestions else emptyList()

      val durationMinutes = customMinutes ?: if (mode == ExamMode.MOCK_MINISTRY) 20 else 30
      val totalSeconds = durationMinutes * 60L

      _uiState.value = ExamUiState(
        subject = subject,
        mode = mode,
        questions = questions,
        currentQuestionIndex = 0,
        selectedAnswers = emptyMap(),
        flaggedQuestions = emptySet(),
        remainingSeconds = totalSeconds,
        totalExamSeconds = totalSeconds,
        isFinished = false,
        isPaused = false,
        isTimeUp = false,
        showExplanation = false,
        completedAttempt = null
      )

      startTimer()
    }
  }

  fun startMistakesExam() {
    viewModelScope.launch {
      val mistakeIds = repository.getMistakeQuestionIds()
      val loadedQuestions = if (mistakeIds.isNotEmpty()) {
        repository.getQuestionsByIds(mistakeIds)
      } else {
        repository.getAllQuestions()
        emptyList()
      }

      val fallbackQuestions = if (loadedQuestions.isEmpty()) {
        repository.getQuestionsForSubjectDirect(Subject.AFAAN_OROMOO.id).take(5)
      } else loadedQuestions

      _uiState.value = ExamUiState(
        subject = Subject.AFAAN_OROMOO,
        mode = ExamMode.PRACTICE,
        questions = fallbackQuestions,
        currentQuestionIndex = 0,
        selectedAnswers = emptyMap(),
        remainingSeconds = 20 * 60L,
        totalExamSeconds = 20 * 60L,
        isFinished = false
      )
      startTimer()
    }
  }

  private fun startTimer() {
    timerJob?.cancel()
    examEndTimeMillis = SystemClock.elapsedRealtime() + _uiState.value.remainingSeconds * 1000L
    timerJob = viewModelScope.launch {
      while (_uiState.value.remainingSeconds > 0 && !_uiState.value.isFinished) {
        delay(500)
        if (!_uiState.value.isPaused && !_uiState.value.isFinished) {
          val remaining = maxOf(0L, (examEndTimeMillis - SystemClock.elapsedRealtime() + 999L) / 1000L)
          _uiState.update { current ->
            if (remaining <= 0) {
              current.copy(remainingSeconds = 0, isTimeUp = true)
            } else {
              current.copy(remainingSeconds = remaining)
            }
          }
          if (_uiState.value.remainingSeconds <= 0) {
            submitExam()
            break
          }
        }
      }
    }
  }

  fun selectOption(optionIndex: Int) {
    val currentQ = currentQuestion ?: return
    _uiState.update { state ->
      val newAnswers = state.selectedAnswers.toMutableMap()
      newAnswers[currentQ.id] = optionIndex
      state.copy(
        selectedAnswers = newAnswers,
        showExplanation = state.mode == ExamMode.PRACTICE // in practice mode, reveal explanation instantly
      )
    }
  }

  fun nextQuestion() {
    _uiState.update { state ->
      if (state.currentQuestionIndex < state.questions.size - 1) {
        state.copy(
          currentQuestionIndex = state.currentQuestionIndex + 1,
          showExplanation = false
        )
      } else state
    }
  }

  fun previousQuestion() {
    _uiState.update { state ->
      if (state.currentQuestionIndex > 0) {
        state.copy(
          currentQuestionIndex = state.currentQuestionIndex - 1,
          showExplanation = false
        )
      } else state
    }
  }

  fun jumpToQuestion(index: Int) {
    if (index in 0 until _uiState.value.questions.size) {
      _uiState.update { it.copy(currentQuestionIndex = index, showExplanation = false) }
    }
  }

  fun toggleFlagCurrentQuestion() {
    val qId = currentQuestion?.id ?: return
    _uiState.update { state ->
      val newFlags = state.flaggedQuestions.toMutableSet()
      if (newFlags.contains(qId)) newFlags.remove(qId) else newFlags.add(qId)
      state.copy(flaggedQuestions = newFlags)
    }
  }

  fun toggleBookmark(questionId: String) {
    viewModelScope.launch {
      val isSaved = repository.toggleBookmark(questionId)
      _uiState.update { state ->
        val newBookmarks = state.bookmarkedQuestions.toMutableSet()
        if (isSaved) newBookmarks.add(questionId) else newBookmarks.remove(questionId)
        state.copy(bookmarkedQuestions = newBookmarks)
      }
    }
  }

  fun toggleBookmarkCurrentQuestion() {
    val qId = currentQuestion?.id ?: return
    toggleBookmark(qId)
  }

  fun togglePause() {
    _uiState.update { current ->
      val newPaused = !current.isPaused
      if (!newPaused) {
        examEndTimeMillis = SystemClock.elapsedRealtime() + current.remainingSeconds * 1000L
      }
      current.copy(isPaused = newPaused)
    }
  }

  fun submitExam() {
    timerJob?.cancel()
    val state = _uiState.value
    if (state.isFinished) return

    val questions = state.questions
    var correctCount = 0
    val encodedAnswers = StringBuilder()

    for (q in questions) {
      val selected = state.selectedAnswers[q.id]
      val isCorrect = selected != null && selected == q.correctOptionIndex
      if (isCorrect) correctCount++
      if (encodedAnswers.isNotEmpty()) encodedAnswers.append(";")
      encodedAnswers.append("${q.id}:${selected ?: -1}:${if (isCorrect) "1" else "0"}")
    }

    val total = questions.size
    val percentage = if (total > 0) (correctCount * 100) / total else 0
    val timeTaken = state.totalExamSeconds - state.remainingSeconds

    val attempt = ExamAttemptEntity(
      id = UUID.randomUUID().toString(),
      subjectId = state.subject.id,
      examType = state.mode.name,
      totalQuestions = total,
      correctAnswersCount = correctCount,
      scorePercentage = percentage,
      timeTakenSeconds = timeTaken,
      timestamp = System.currentTimeMillis(),
      userAnswersMapJson = encodedAnswers.toString(),
      isSynced = false
    )

    viewModelScope.launch {
      repository.saveExamAttempt(attempt)
      _uiState.update {
        it.copy(
          isFinished = true,
          completedAttempt = attempt
        )
      }
    }
  }

  val currentQuestion: QuestionEntity?
    get() {
      val state = _uiState.value
      return if (state.questions.isNotEmpty() && state.currentQuestionIndex in state.questions.indices) {
        state.questions[state.currentQuestionIndex]
      } else null
    }

  override fun onCleared() {
    super.onCleared()
    timerJob?.cancel()
  }
}
