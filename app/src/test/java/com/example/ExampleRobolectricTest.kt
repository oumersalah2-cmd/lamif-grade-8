package com.example

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

import com.example.features.schedule.notifications.StudyNotificationHelper
import com.example.features.schedule.notifications.StudyReminderScheduler
import org.junit.Assert.assertTrue

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [36])
class ExampleRobolectricTest {

  @Test
  fun `read string from context`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    val appName = context.getString(R.string.app_name)
    assertEquals("Lamif Kutaa 8 Prep", appName)
  }

  @Test
  fun `test study reminder scheduler persistence`() {
    val context = ApplicationProvider.getApplicationContext<Context>()

    StudyReminderScheduler.saveReminderSettings(
      context = context,
      enabled = true,
      hour = 18,
      minute = 30
    )

    assertEquals(true, StudyReminderScheduler.isReminderEnabled(context))
    assertEquals(18, StudyReminderScheduler.getReminderHour(context))
    assertEquals(30, StudyReminderScheduler.getReminderMinute(context))
  }

  @Test
  fun `test reminder trigger millis is in the future`() {
    val nextTrigger = StudyReminderScheduler.calculateNextTriggerMillis(17, 0)
    assertTrue("Trigger must be strictly greater than current time", nextTrigger > System.currentTimeMillis() - 1000)
  }

  @Test
  fun `test notification channel initialization`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    StudyNotificationHelper.createNotificationChannel(context)
    val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
    val channel = manager.getNotificationChannel(StudyNotificationHelper.CHANNEL_ID)
    assertEquals("Yaadachiisa Qo'annoo (Study Reminders)", channel.name)
  }

  @Test
  fun `test theme manager persistence and mode switching`() {
    val context = ApplicationProvider.getApplicationContext<Context>()
    val themeManager = com.example.ui.theme.AppThemeManager.getInstance(context)

    themeManager.setThemeMode(com.example.ui.theme.AppThemeMode.DARK)
    assertEquals(com.example.ui.theme.AppThemeMode.DARK, themeManager.themeMode.value)

    themeManager.setThemeMode(com.example.ui.theme.AppThemeMode.LIGHT)
    assertEquals(com.example.ui.theme.AppThemeMode.LIGHT, themeManager.themeMode.value)

    themeManager.toggleLightDark(currentlyDark = false)
    assertEquals(com.example.ui.theme.AppThemeMode.DARK, themeManager.themeMode.value)

    themeManager.toggleLightDark(currentlyDark = true)
    assertEquals(com.example.ui.theme.AppThemeMode.LIGHT, themeManager.themeMode.value)
  }
}
