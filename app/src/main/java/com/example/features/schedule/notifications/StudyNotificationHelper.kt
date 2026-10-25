package com.example.features.schedule.notifications

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.example.MainActivity

/**
 * Helper utility for creating notification channels and posting
 * high-priority, motivational Grade 8 study reminders in Afaan Oromoo.
 */
object StudyNotificationHelper {

  const val CHANNEL_ID = "lamif_study_reminders_channel"
  const val NOTIFICATION_ID_DAILY = 8001
  const val NOTIFICATION_ID_TEST = 8002

  const val EXTRA_OPEN_SCREEN = "EXTRA_OPEN_SCREEN"
  const val SCREEN_SCHEDULE = "SCHEDULE"

  /**
   * Initializes notification channel on Android 8.0+ (Oreo, API 26+)
   */
  fun createNotificationChannel(context: Context) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val name = "Yaadachiisa Qo'annoo (Study Reminders)"
      val descriptionText = "Yaadachiisa guyyaa guyyaan sagantaa qo'annoo barattoota kutaa 8ffaatiif ergamu."
      val importance = NotificationManager.IMPORTANCE_HIGH

      val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
        description = descriptionText
        enableLights(true)
        lightColor = Color.parseColor("#1B6E32")
        enableVibration(true)
        vibrationPattern = longArrayOf(0, 300, 200, 300)
        setShowBadge(true)
      }

      val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
      notificationManager.createNotificationChannel(channel)
    }
  }

  /**
   * Check if notification permission is granted (specifically required on Android 13+)
   */
  fun hasNotificationPermission(context: Context): Boolean {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      ContextCompat.checkSelfPermission(
        context,
        android.Manifest.permission.POST_NOTIFICATIONS
      ) == PackageManager.PERMISSION_GRANTED
    } else {
      NotificationManagerCompat.from(context).areNotificationsEnabled()
    }
  }

  /**
   * Posts the daily study session reminder notification.
   */
  fun showStudyReminder(
    context: Context,
    title: String,
    message: String,
    subText: String = "Lamif Kutaa 8",
    notificationId: Int = NOTIFICATION_ID_DAILY
  ) {
    createNotificationChannel(context)

    if (!hasNotificationPermission(context)) {
      return
    }

    // Intent to open MainActivity directly into the Schedule Screen
    val intent = Intent(context, MainActivity::class.java).apply {
      flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
      putExtra(EXTRA_OPEN_SCREEN, SCREEN_SCHEDULE)
    }

    val pendingIntent = PendingIntent.getActivity(
      context,
      notificationId,
      intent,
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val notificationBuilder = NotificationCompat.Builder(context, CHANNEL_ID)
      .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
      .setContentTitle(title)
      .setContentText(message)
      .setSubText(subText)
      .setStyle(
        NotificationCompat.BigTextStyle()
          .bigText("$message\n\nQabxii olaanaa fiduuf har'as daqiiqaa muraasaaf qayyabadhu! 📚✨")
          .setSummaryText("Qophii Qormaataa")
      )
      .setColor(Color.parseColor("#1B6E32")) // Trustworthy deep green
      .setPriority(NotificationCompat.PRIORITY_HIGH)
      .setCategory(NotificationCompat.CATEGORY_REMINDER)
      .setContentIntent(pendingIntent)
      .setAutoCancel(true)
      .setDefaults(NotificationCompat.DEFAULT_ALL)

    try {
      NotificationManagerCompat.from(context).notify(notificationId, notificationBuilder.build())
    } catch (_: SecurityException) {
      // Permission revoked at runtime
    }
  }
}
