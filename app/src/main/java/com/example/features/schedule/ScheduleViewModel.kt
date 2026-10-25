package com.example.features.schedule

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.example.data.local.AppDatabase
import com.example.data.local.entities.StudySessionEntity
import com.example.data.model.Subject
import com.example.data.repository.ScheduleRepository
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.util.UUID

enum class DayOfWeekOm(val id: String, val shortNameOm: String, val fullNameOm: String) {
  WIIXATA("WIIXATA", "Wix", "Wiixata (Mon)"),
  KIBXATA("KIBXATA", "Kib", "Kibxata (Tue)"),
  ROOBII("ROOBII", "Roob", "Roobii (Wed)"),
  KAMISA("KAMISA", "Kam", "Kamisa (Thu)"),
  JIMAATA("JIMAATA", "Jim", "Jimaata (Fri)"),
  SANBATA("SANBATA", "San", "Sanbata (Sat)"),
  DILBATA("DILBATA", "Dil", "Dilbata (Sun)")
}

class ScheduleViewModel(application: Application) : AndroidViewModel(application) {
  private val repository = ScheduleRepository(AppDatabase.getDatabase(application))
  private val context = application.applicationContext

  private val _selectedDay = MutableStateFlow(DayOfWeekOm.WIIXATA)
  val selectedDay: StateFlow<DayOfWeekOm> = _selectedDay.asStateFlow()

  // Daily reminder notification states
  private val _reminderEnabled = MutableStateFlow(
    com.example.features.schedule.notifications.StudyReminderScheduler.isReminderEnabled(context)
  )
  val reminderEnabled: StateFlow<Boolean> = _reminderEnabled.asStateFlow()

  private val _reminderHour = MutableStateFlow(
    com.example.features.schedule.notifications.StudyReminderScheduler.getReminderHour(context)
  )
  val reminderHour: StateFlow<Int> = _reminderHour.asStateFlow()

  private val _reminderMinute = MutableStateFlow(
    com.example.features.schedule.notifications.StudyReminderScheduler.getReminderMinute(context)
  )
  val reminderMinute: StateFlow<Int> = _reminderMinute.asStateFlow()

  private val _hasNotificationPermission = MutableStateFlow(
    com.example.features.schedule.notifications.StudyNotificationHelper.hasNotificationPermission(context)
  )
  val hasNotificationPermission: StateFlow<Boolean> = _hasNotificationPermission.asStateFlow()

  init {
    com.example.features.schedule.notifications.StudyNotificationHelper.createNotificationChannel(context)
    if (_reminderEnabled.value) {
      com.example.features.schedule.notifications.StudyReminderScheduler.scheduleDailyReminder(context)
    }
  }

  fun refreshPermissionStatus() {
    _hasNotificationPermission.value =
      com.example.features.schedule.notifications.StudyNotificationHelper.hasNotificationPermission(context)
  }

  fun setReminderEnabled(enabled: Boolean) {
    _reminderEnabled.value = enabled
    com.example.features.schedule.notifications.StudyReminderScheduler.saveReminderSettings(
      context = context,
      enabled = enabled,
      hour = _reminderHour.value,
      minute = _reminderMinute.value
    )
  }

  fun setReminderTime(hour: Int, minute: Int) {
    _reminderHour.value = hour
    _reminderMinute.value = minute
    com.example.features.schedule.notifications.StudyReminderScheduler.saveReminderSettings(
      context = context,
      enabled = _reminderEnabled.value,
      hour = hour,
      minute = minute
    )
  }

  fun sendTestReminder() {
    com.example.features.schedule.notifications.StudyReminderScheduler.sendImmediateTestReminder(context)
  }

  @OptIn(ExperimentalCoroutinesApi::class)
  val sessionsForSelectedDay: StateFlow<List<StudySessionEntity>> = _selectedDay
    .flatMapLatest { day ->
      repository.getSessionsForDay(day.id)
    }
    .stateIn(
      scope = viewModelScope,
      started = SharingStarted.WhileSubscribed(5000),
      initialValue = emptyList()
    )

  fun selectDay(day: DayOfWeekOm) {
    _selectedDay.value = day
  }

  fun toggleCompleted(session: StudySessionEntity) {
    viewModelScope.launch {
      repository.toggleSessionCompleted(session.id, !session.isCompleted)
    }
  }

  fun deleteSession(session: StudySessionEntity) {
    viewModelScope.launch {
      repository.deleteSession(session.id)
    }
  }

  fun addStudySession(
    subject: Subject,
    startTime: String,
    durationMinutes: Int,
    topicFocus: String
  ) {
    viewModelScope.launch {
      val newSession = StudySessionEntity(
        id = UUID.randomUUID().toString(),
        subjectId = subject.id,
        dayOfWeek = _selectedDay.value.id,
        startTime = startTime,
        durationMinutes = durationMinutes,
        topicFocusOm = topicFocus.ifBlank { "Qo'annoo ${subject.afaanOromoName}" },
        isCompleted = false
      )
      repository.addSession(newSession)
    }
  }
}
