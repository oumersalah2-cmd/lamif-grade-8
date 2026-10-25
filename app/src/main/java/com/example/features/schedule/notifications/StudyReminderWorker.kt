package com.example.features.schedule.notifications

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.example.data.local.AppDatabase
import java.util.Calendar

/**
 * Background WorkManager worker providing guaranteed backup delivery
 * for daily study session reminders, especially under aggressive battery optimization.
 */
class StudyReminderWorker(
  private val context: Context,
  workerParams: WorkerParameters
) : CoroutineWorker(context, workerParams) {

  override suspend fun doWork(): Result {
    if (!StudyReminderScheduler.isReminderEnabled(context)) {
      return Result.success()
    }

    try {
      val todayId = when (Calendar.getInstance().get(Calendar.DAY_OF_WEEK)) {
        Calendar.MONDAY -> "WIIXATA"
        Calendar.TUESDAY -> "KIBXATA"
        Calendar.WEDNESDAY -> "ROOBII"
        Calendar.THURSDAY -> "KAMISA"
        Calendar.FRIDAY -> "JIMAATA"
        Calendar.SATURDAY -> "SANBATA"
        Calendar.SUNDAY -> "DILBATA"
        else -> "WIIXATA"
      }

      val db = AppDatabase.getDatabase(context)
      val sessions = db.studySessionDao().getSessionsListForDay(todayId)
      val uncompleted = sessions.filter { !it.isCompleted }

      val title = if (uncompleted.isNotEmpty()) {
        "Yeroon Qo'annoo Har'aa Ga'eera! 📚"
      } else {
        "Qophii Qormaataa Kutaa 8ffaa ⏰"
      }

      val message = if (uncompleted.isNotEmpty()) {
        val subjectNames = uncompleted.joinToString(", ") { session ->
          session.subjectId.replace("_", " ").replaceFirstChar { it.uppercase() }
        }
        "Barnoota ${uncompleted.size} qayyabachuuf qophaa'i: $subjectNames."
      } else {
        "Sagantaa qo'annoo kee qayyabadhuutii qabxii olaanaa fidi!"
      }

      StudyNotificationHelper.showStudyReminder(
        context = context,
        title = title,
        message = message,
        subText = "Yaadachiisa Qo'annoo"
      )

      return Result.success()
    } catch (_: Exception) {
      return Result.retry()
    }
  }
}
