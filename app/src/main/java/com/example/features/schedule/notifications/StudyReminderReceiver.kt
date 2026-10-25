package com.example.features.schedule.notifications

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.data.local.AppDatabase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Calendar

/**
 * BroadcastReceiver triggered by AlarmManager or Device Reboot
 * to present personalized study session reminders in Afaan Oromoo.
 */
class StudyReminderReceiver : BroadcastReceiver() {

  override fun onReceive(context: Context, intent: Intent?) {
    val action = intent?.action

    if (action == Intent.ACTION_BOOT_COMPLETED || action == Intent.ACTION_MY_PACKAGE_REPLACED) {
      // Re-register alarms after system reboot or app update
      StudyReminderScheduler.scheduleDailyReminder(context)
      return
    }

    if (!StudyReminderScheduler.isReminderEnabled(context)) {
      return
    }

    // GoAsync to allow coroutine execution for Room query
    val pendingResult = goAsync()
    CoroutineScope(Dispatchers.IO).launch {
      try {
        val todayId = getTodayDayOfWeekId()
        val db = AppDatabase.getDatabase(context)
        val sessions = db.studySessionDao().getSessionsListForDay(todayId)

        val uncompleted = sessions.filter { !it.isCompleted }

        val title: String
        val message: String

        if (uncompleted.isNotEmpty()) {
          val subjectNames = uncompleted.joinToString(", ") { session ->
            session.subjectId.replace("_", " ").replaceFirstChar { it.uppercase() }
          }
          title = "Yeroon Qo'annoo Har'aa Ga'eera! 📚"
          message = "Barnoota har'aa: $subjectNames. Seeniitii qayyabadhu!"
        } else if (sessions.isNotEmpty()) {
          title = "Baga Gammaddan! 🎉"
          message = "Barnoota har'aa hunda xumurteetta. Qabxii qormaataa fooyyessuuf jabaadhu!"
        } else {
          title = "Qophii Qormaataa Kutaa 8ffaa ⏰"
          message = "Qormaata Ministeeraa fi Ifa Boruutiif har'as yeroo kee qisaasessin qayyabadhu."
        }

        StudyNotificationHelper.showStudyReminder(
          context = context,
          title = title,
          message = message,
          subText = "Sagantaa Har'aa"
        )
      } catch (_: Exception) {
        // Fallback notification if DB query fails
        StudyNotificationHelper.showStudyReminder(
          context = context,
          title = "Yeroon Qo'annoo Kee Ga'eera! ⏰",
          message = "Qophii qormaata kutaa 8ffaatiif sagantaa kee qayyabadhuutii of qopheessi.",
          subText = "Lamif Kutaa 8"
        )
      } finally {
        // Automatically schedule for tomorrow
        StudyReminderScheduler.scheduleDailyReminder(context)
        pendingResult.finish()
      }
    }
  }

  private fun getTodayDayOfWeekId(): String {
    return when (Calendar.getInstance().get(Calendar.DAY_OF_WEEK)) {
      Calendar.MONDAY -> "WIIXATA"
      Calendar.TUESDAY -> "KIBXATA"
      Calendar.WEDNESDAY -> "ROOBII"
      Calendar.THURSDAY -> "KAMISA"
      Calendar.FRIDAY -> "JIMAATA"
      Calendar.SATURDAY -> "SANBATA"
      Calendar.SUNDAY -> "DILBATA"
      else -> "WIIXATA"
    }
  }
}
