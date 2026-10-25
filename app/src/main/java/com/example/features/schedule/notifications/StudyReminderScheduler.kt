package com.example.features.schedule.notifications

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.Calendar
import java.util.concurrent.TimeUnit

/**
 * Manages scheduling, rescheduling, and cancellation of the daily
 * study reminder notification system using AlarmManager & WorkManager.
 */
object StudyReminderScheduler {

  const val PREFS_NAME = "lamif_study_notification_prefs"
  const val KEY_REMINDER_ENABLED = "study_reminder_enabled"
  const val KEY_REMINDER_HOUR = "study_reminder_hour"
  const val KEY_REMINDER_MINUTE = "study_reminder_minute"

  const val ACTION_STUDY_REMINDER = "com.example.ACTION_STUDY_REMINDER"
  private const val ALARM_REQUEST_CODE = 9001
  private const val WORK_TAG_DAILY_REMINDER = "work_lamif_daily_reminder"

  // Default reminder time: 17:00 (5:00 PM - Ideal study hour after school)
  const val DEFAULT_HOUR = 17
  const val DEFAULT_MINUTE = 0

  fun isReminderEnabled(context: Context): Boolean {
    val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    return prefs.getBoolean(KEY_REMINDER_ENABLED, true)
  }

  fun getReminderHour(context: Context): Int {
    val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    return prefs.getInt(KEY_REMINDER_HOUR, DEFAULT_HOUR)
  }

  fun getReminderMinute(context: Context): Int {
    val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    return prefs.getInt(KEY_REMINDER_MINUTE, DEFAULT_MINUTE)
  }

  fun saveReminderSettings(context: Context, enabled: Boolean, hour: Int, minute: Int) {
    val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    prefs.edit()
      .putBoolean(KEY_REMINDER_ENABLED, enabled)
      .putInt(KEY_REMINDER_HOUR, hour)
      .putInt(KEY_REMINDER_MINUTE, minute)
      .apply()

    if (enabled) {
      scheduleDailyReminder(context)
    } else {
      cancelDailyReminder(context)
    }
  }

  /**
   * Calculates the next trigger timestamp for the daily reminder.
   */
  fun calculateNextTriggerMillis(hour: Int, minute: Int): Long {
    val now = Calendar.getInstance()
    val target = Calendar.getInstance().apply {
      set(Calendar.HOUR_OF_DAY, hour)
      set(Calendar.MINUTE, minute)
      set(Calendar.SECOND, 0)
      set(Calendar.MILLISECOND, 0)
    }

    if (target.before(now)) {
      target.add(Calendar.DAY_OF_YEAR, 1)
    }
    return target.timeInMillis
  }

  /**
   * Schedules the daily study session reminder using AlarmManager and WorkManager.
   */
  fun scheduleDailyReminder(context: Context) {
    if (!isReminderEnabled(context)) return

    val hour = getReminderHour(context)
    val minute = getReminderMinute(context)
    val triggerMillis = calculateNextTriggerMillis(hour, minute)

    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    val intent = Intent(context, StudyReminderReceiver::class.java).apply {
      action = ACTION_STUDY_REMINDER
    }

    val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    } else {
      PendingIntent.FLAG_UPDATE_CURRENT
    }

    val pendingIntent = PendingIntent.getBroadcast(
      context,
      ALARM_REQUEST_CODE,
      intent,
      flags
    )

    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        // Allows firing even during Doze / Battery saving mode
        alarmManager.setAndAllowWhileIdle(
          AlarmManager.RTC_WAKEUP,
          triggerMillis,
          pendingIntent
        )
      } else {
        alarmManager.set(
          AlarmManager.RTC_WAKEUP,
          triggerMillis,
          pendingIntent
        )
      }
    } catch (_: Exception) {
      // Fallback handled by WorkManager
    }

    // Schedule WorkManager periodic backup for battery-managed devices
    scheduleWorkManagerBackup(context, hour, minute)
  }

  private fun scheduleWorkManagerBackup(context: Context, hour: Int, minute: Int) {
    try {
      val now = Calendar.getInstance()
      val target = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, hour)
        set(Calendar.MINUTE, minute)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
      }
      if (target.before(now)) {
        target.add(Calendar.DAY_OF_YEAR, 1)
      }

      val initialDelayMillis = target.timeInMillis - now.timeInMillis

      val dailyWorkRequest = PeriodicWorkRequestBuilder<StudyReminderWorker>(
        24, TimeUnit.HOURS,
        15, TimeUnit.MINUTES // 15-minute flex interval
      )
        .setInitialDelay(initialDelayMillis, TimeUnit.MILLISECONDS)
        .addTag(WORK_TAG_DAILY_REMINDER)
        .build()

      WorkManager.getInstance(context).enqueueUniquePeriodicWork(
        WORK_TAG_DAILY_REMINDER,
        ExistingPeriodicWorkPolicy.UPDATE,
        dailyWorkRequest
      )
    } catch (_: Exception) {
      // Safe no-op
    }
  }

  /**
   * Cancels scheduled reminders
   */
  fun cancelDailyReminder(context: Context) {
    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    val intent = Intent(context, StudyReminderReceiver::class.java).apply {
      action = ACTION_STUDY_REMINDER
    }
    val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    } else {
      PendingIntent.FLAG_UPDATE_CURRENT
    }
    val pendingIntent = PendingIntent.getBroadcast(
      context,
      ALARM_REQUEST_CODE,
      intent,
      flags
    )
    alarmManager.cancel(pendingIntent)

    try {
      WorkManager.getInstance(context).cancelUniqueWork(WORK_TAG_DAILY_REMINDER)
    } catch (_: Exception) {}
  }

  /**
   * Sends an immediate test reminder in Afaan Oromoo so the student can preview it.
   */
  fun sendImmediateTestReminder(context: Context) {
    StudyNotificationHelper.showStudyReminder(
      context = context,
      title = "Yeroon Qo'annoo Kee Ga'eera! ⏰",
      message = "Qophii qormaata kutaa 8ffaatiif sagantaa har'aa qayyabadhuutii of qopheessi.",
      subText = "Yaalii Yaadachiisaa",
      notificationId = StudyNotificationHelper.NOTIFICATION_ID_TEST
    )
  }
}
