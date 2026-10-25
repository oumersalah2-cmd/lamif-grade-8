package com.example.features.home

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.local.AppDatabase
import com.example.data.local.entities.ExamAttemptEntity
import com.example.data.local.entities.UserProfileEntity
import com.example.data.model.Subject
import com.example.data.repository.ExamRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class HomeUiState(
  val studentName: String = "Barataa Kutaa 8ffaa",
  val zoneName: String = "Shawaa Bahaa",
  val schoolName: String = "Mana Barumsaa Sad. 1ffaa",
  val streakDays: Int = 3,
  val targetScore: Int = 90,
  val totalExamsTaken: Int = 0,
  val averageScore: Int = 0,
  val pendingSyncCount: Int = 0,
  val isSyncing: Boolean = false,
  val syncMessage: String? = null,
  val recentAttempts: List<ExamAttemptEntity> = emptyList(),
  val mistakeQuestionsCount: Int = 0
)

class HomeViewModel(application: Application) : AndroidViewModel(application) {
  private val repository = ExamRepository(AppDatabase.getDatabase(application))

  private val _isSyncing = MutableStateFlow(false)
  val isSyncing: StateFlow<Boolean> = _isSyncing.asStateFlow()

  private val _syncMessage = MutableStateFlow<String?>(null)
  val syncMessage: StateFlow<String?> = _syncMessage.asStateFlow()

  val uiState: StateFlow<HomeUiState> = combine(
    repository.getUserProfile(),
    repository.getAllAttempts(),
    repository.getPendingSyncCount(),
    _isSyncing,
    _syncMessage
  ) { profile, attempts, pendingSync, syncing, msg ->
    val avg = if (attempts.isNotEmpty()) {
      attempts.map { it.scorePercentage }.average().toInt()
    } else 0

    HomeUiState(
      studentName = profile?.fullName ?: "Barataa Kutaa 8ffaa",
      zoneName = profile?.zoneName ?: "Shawaa Bahaa",
      schoolName = profile?.schoolName ?: "Mana Barumsaa Sad. 1ffaa",
      streakDays = profile?.streakDays ?: 3,
      targetScore = profile?.targetScore ?: 90,
      totalExamsTaken = attempts.size,
      averageScore = avg,
      pendingSyncCount = pendingSync,
      isSyncing = syncing,
      syncMessage = msg,
      recentAttempts = attempts.take(5)
    )
  }.stateIn(
    scope = viewModelScope,
    started = SharingStarted.WhileSubscribed(5000),
    initialValue = HomeUiState()
  )

  init {
    refreshMistakesCount()
  }

  fun triggerSync() {
    viewModelScope.launch {
      _isSyncing.value = true
      _syncMessage.value = "Qabxiin gara daataa biirootti qindaa'aa jira..."
      val synced = repository.syncPendingData()
      _isSyncing.value = false
      _syncMessage.value = if (synced > 0) {
        "Qormaata $synced milkaa'inaan qindaa'eera (Synced!)"
      } else {
        "Daataan haaraan qindaa'u hin jiru. Qophii dha!"
      }
    }
  }

  fun clearSyncMessage() {
    _syncMessage.value = null
  }

  private fun refreshMistakesCount() {
    viewModelScope.launch {
      val ids = repository.getMistakeQuestionIds()
      // can be updated if needed
    }
  }
}
