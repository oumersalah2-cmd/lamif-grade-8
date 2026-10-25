package com.example.features.schedule.components

import android.os.Build
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccessTime
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.NotificationsActive
import androidx.compose.material.icons.filled.NotificationsOff
import androidx.compose.material.icons.filled.NotificationsPaused
import androidx.compose.material.icons.filled.Send
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.util.Locale

/**
 * Material 3 Card allowing students to enable, configure, and test
 * daily study reminder notifications in Afaan Oromoo.
 */
@Composable
fun StudyReminderCard(
  reminderEnabled: Boolean,
  reminderHour: Int,
  reminderMinute: Int,
  hasPermission: Boolean,
  onToggleEnabled: (Boolean) -> Unit,
  onTimeChanged: (Int, Int) -> Unit,
  onSendTestNotification: () -> Unit,
  onPermissionRefreshed: () -> Unit,
  modifier: Modifier = Modifier
) {
  var showTimeDialog by remember { mutableStateOf(false) }
  var testNotificationSent by remember { mutableStateOf(false) }

  // Permission launcher for Android 13+ (POST_NOTIFICATIONS)
  val permissionLauncher = rememberLauncherForActivityResult(
    contract = ActivityResultContracts.RequestPermission()
  ) { isGranted ->
    onPermissionRefreshed()
  }

  Card(
    shape = RoundedCornerShape(20.dp),
    colors = CardDefaults.cardColors(
      containerColor = MaterialTheme.colorScheme.surface
    ),
    border = androidx.compose.foundation.BorderStroke(
      width = 1.dp,
      color = if (reminderEnabled) MaterialTheme.colorScheme.primary.copy(alpha = 0.3f)
      else MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.4f)
    ),
    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    modifier = modifier
      .fillMaxWidth()
      .testTag("study_reminder_card")
  ) {
    Column(
      modifier = Modifier
        .fillMaxWidth()
        .padding(18.dp)
    ) {
      // Header: Icon, Title & Toggle Switch
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Row(
          verticalAlignment = Alignment.CenterVertically,
          modifier = Modifier.weight(1f)
        ) {
          Surface(
            shape = CircleShape,
            color = if (reminderEnabled) MaterialTheme.colorScheme.primary.copy(alpha = 0.12f)
            else MaterialTheme.colorScheme.surfaceVariant,
            modifier = Modifier.size(44.dp)
          ) {
            Box(contentAlignment = Alignment.Center) {
              Icon(
                imageVector = if (reminderEnabled) Icons.Default.NotificationsActive
                else Icons.Default.NotificationsOff,
                contentDescription = null,
                tint = if (reminderEnabled) MaterialTheme.colorScheme.primary
                else MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.size(24.dp)
              )
            }
          }

          Spacer(modifier = Modifier.width(12.dp))

          Column {
            Text(
              text = "Yaadachiisa Qo'annoo",
              fontWeight = FontWeight.Bold,
              fontSize = 16.sp,
              color = MaterialTheme.colorScheme.onSurface
            )
            Text(
              text = "Daily Study Reminder",
              fontSize = 11.5.sp,
              color = MaterialTheme.colorScheme.onSurfaceVariant
            )
          }
        }

        Switch(
          checked = reminderEnabled,
          onCheckedChange = { isChecked ->
            if (isChecked && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && !hasPermission) {
              permissionLauncher.launch(android.Manifest.permission.POST_NOTIFICATIONS)
            }
            onToggleEnabled(isChecked)
          },
          colors = SwitchDefaults.colors(
            checkedThumbColor = Color.White,
            checkedTrackColor = MaterialTheme.colorScheme.primary
          ),
          modifier = Modifier.testTag("reminder_toggle_switch")
        )
      }

      // Permission Warning Banner if missing on Android 13+
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && !hasPermission && reminderEnabled) {
        Spacer(modifier = Modifier.height(14.dp))
        Surface(
          shape = RoundedCornerShape(12.dp),
          color = MaterialTheme.colorScheme.errorContainer.copy(alpha = 0.7f),
          modifier = Modifier
            .fillMaxWidth()
            .clickable {
              permissionLauncher.launch(android.Manifest.permission.POST_NOTIFICATIONS)
            }
        ) {
          Row(
            modifier = Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
          ) {
            Icon(
              imageVector = Icons.Default.NotificationsPaused,
              contentDescription = null,
              tint = MaterialTheme.colorScheme.onErrorContainer,
              modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.width(10.dp))
            Column(modifier = Modifier.weight(1f)) {
              Text(
                text = "Hayyama Yaadachiisaa Kennaa",
                fontWeight = FontWeight.Bold,
                fontSize = 12.5.sp,
                color = MaterialTheme.colorScheme.onErrorContainer
              )
              Text(
                text = "Yaadachiisni guyyaa guyyaa akka si ga'uuf eeyyama kenni.",
                fontSize = 11.sp,
                color = MaterialTheme.colorScheme.onErrorContainer.copy(alpha = 0.9f)
              )
            }
            TextButton(
              onClick = {
                permissionLauncher.launch(android.Manifest.permission.POST_NOTIFICATIONS)
              }
            ) {
              Text("Eeyyami", fontWeight = FontWeight.Bold, fontSize = 12.sp)
            }
          }
        }
      }

      // Reminder Details & Controls
      AnimatedVisibility(
        visible = reminderEnabled,
        enter = fadeIn(),
        exit = fadeOut()
      ) {
        Column(modifier = Modifier.padding(top = 16.dp)) {
          // Time display row
          Surface(
            shape = RoundedCornerShape(14.dp),
            color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.45f),
            modifier = Modifier
              .fillMaxWidth()
              .clickable { showTimeDialog = true }
          ) {
            Row(
              modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 14.dp, vertical = 12.dp),
              horizontalArrangement = Arrangement.SpaceBetween,
              verticalAlignment = Alignment.CenterVertically
            ) {
              Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                  imageVector = Icons.Default.AccessTime,
                  contentDescription = null,
                  tint = MaterialTheme.colorScheme.primary,
                  modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(10.dp))
                Column {
                  Text(
                    text = "Sa'aatii Yaadachiisaa:",
                    fontSize = 11.5.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                  )
                  Text(
                    text = formatTimeString(reminderHour, reminderMinute),
                    fontWeight = FontWeight.Bold,
                    fontSize = 17.sp,
                    color = MaterialTheme.colorScheme.onSurface
                  )
                }
              }

              OutlinedButton(
                onClick = { showTimeDialog = true },
                shape = RoundedCornerShape(10.dp),
                contentPadding = androidx.compose.foundation.layout.PaddingValues(
                  horizontal = 12.dp,
                  vertical = 6.dp
                ),
                modifier = Modifier.testTag("change_reminder_time_btn")
              ) {
                Icon(imageVector = Icons.Default.Edit, contentDescription = null, modifier = Modifier.size(14.dp))
                Spacer(modifier = Modifier.width(6.dp))
                Text("Jijjiiri", fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
              }
            }
          }

          Spacer(modifier = Modifier.height(12.dp))

          // Action row: Test Notification button
          Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
          ) {
            Text(
              text = "Guyyaa guyyaan sa'a kanatti yaadachiisni ni ergama.",
              fontSize = 11.5.sp,
              color = MaterialTheme.colorScheme.onSurfaceVariant,
              modifier = Modifier.weight(1f)
            )

            Button(
              onClick = {
                onSendTestNotification()
                testNotificationSent = true
              },
              shape = RoundedCornerShape(10.dp),
              colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.secondaryContainer,
                contentColor = MaterialTheme.colorScheme.onSecondaryContainer
              ),
              contentPadding = androidx.compose.foundation.layout.PaddingValues(
                horizontal = 12.dp,
                vertical = 6.dp
              ),
              modifier = Modifier.testTag("test_notification_btn")
            ) {
              Icon(imageVector = Icons.Default.Send, contentDescription = null, modifier = Modifier.size(13.dp))
              Spacer(modifier = Modifier.width(6.dp))
              Text("Yaali (Test)", fontSize = 12.sp, fontWeight = FontWeight.Bold)
            }
          }

          if (testNotificationSent) {
            Spacer(modifier = Modifier.height(6.dp))
            Text(
              text = "✓ Yaadachiisni yaalii ergameera! Barruu gubbaa ilaali.",
              fontSize = 11.5.sp,
              color = MaterialTheme.colorScheme.primary,
              fontWeight = FontWeight.SemiBold
            )
          }
        }
      }
    }
  }

  // Time Picker Dialog
  if (showTimeDialog) {
    ReminderTimePickerDialog(
      initialHour = reminderHour,
      initialMinute = reminderMinute,
      onDismiss = { showTimeDialog = false },
      onConfirm = { hour, minute ->
        onTimeChanged(hour, minute)
        showTimeDialog = false
      }
    )
  }
}

/**
 * Custom Time Selection Dialog with popular Grade 8 study presets in Afaan Oromoo.
 */
@Composable
fun ReminderTimePickerDialog(
  initialHour: Int,
  initialMinute: Int,
  onDismiss: () -> Unit,
  onConfirm: (hour: Int, minute: Int) -> Unit
) {
  var selectedHour by remember { mutableIntStateOf(initialHour) }
  var selectedMinute by remember { mutableIntStateOf(initialMinute) }

  val presets = listOf(
    Triple(6, 0, "06:00 (Barii)"),
    Triple(16, 0, "16:00 (Galgala)"),
    Triple(17, 0, "17:00 (Dhiha)"),
    Triple(18, 30, "18:30 (Mugaa)"),
    Triple(20, 0, "20:00 (Halkan)")
  )

  AlertDialog(
    onDismissRequest = onDismiss,
    shape = RoundedCornerShape(20.dp),
    title = {
      Text(
        text = "Yeroo Yaadachiisaa Filadhu",
        fontWeight = FontWeight.Bold,
        fontSize = 17.sp
      )
    },
    text = {
      Column(modifier = Modifier.fillMaxWidth()) {
        Text(
          text = "Yeroo qo'annoo guyyaa guyyaan itti eegaltu filadhu:",
          fontSize = 13.sp,
          color = MaterialTheme.colorScheme.onSurfaceVariant
        )

        Spacer(modifier = Modifier.height(14.dp))

        // Quick Presets
        Text(
          text = "Filannoo Baratamoo:",
          fontWeight = FontWeight.SemiBold,
          fontSize = 12.sp,
          color = MaterialTheme.colorScheme.primary
        )
        Spacer(modifier = Modifier.height(6.dp))

        LazyRow(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
          items(presets) { (hour, minute, label) ->
            val isSelected = selectedHour == hour && selectedMinute == minute
            FilterChip(
              selected = isSelected,
              onClick = {
                selectedHour = hour
                selectedMinute = minute
              },
              label = { Text(label, fontSize = 11.5.sp) },
              shape = RoundedCornerShape(10.dp)
            )
          }
        }

        Spacer(modifier = Modifier.height(18.dp))

        // Hour & Minute Selectors
        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.Center,
          verticalAlignment = Alignment.CenterVertically
        ) {
          // Hour Picker
          Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text("Sa'aatii", fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Spacer(modifier = Modifier.height(4.dp))
            Surface(
              shape = RoundedCornerShape(12.dp),
              color = MaterialTheme.colorScheme.primaryContainer,
              modifier = Modifier.padding(4.dp)
            ) {
              Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
              ) {
                IconButton(
                  onClick = { selectedHour = if (selectedHour > 0) selectedHour - 1 else 23 },
                  modifier = Modifier.size(32.dp)
                ) {
                  Text("◀", fontSize = 12.sp)
                }
                Text(
                  text = String.format(Locale.US, "%02d", selectedHour),
                  fontWeight = FontWeight.Bold,
                  fontSize = 22.sp,
                  color = MaterialTheme.colorScheme.onPrimaryContainer,
                  modifier = Modifier.padding(horizontal = 10.dp)
                )
                IconButton(
                  onClick = { selectedHour = (selectedHour + 1) % 24 },
                  modifier = Modifier.size(32.dp)
                ) {
                  Text("▶", fontSize = 12.sp)
                }
              }
            }
          }

          Text(
            text = ":",
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(horizontal = 6.dp)
          )

          // Minute Picker
          Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text("Daqiiqaa", fontSize = 11.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Spacer(modifier = Modifier.height(4.dp))
            Surface(
              shape = RoundedCornerShape(12.dp),
              color = MaterialTheme.colorScheme.primaryContainer,
              modifier = Modifier.padding(4.dp)
            ) {
              Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
              ) {
                IconButton(
                  onClick = {
                    selectedMinute = if (selectedMinute >= 15) selectedMinute - 15 else 45
                  },
                  modifier = Modifier.size(32.dp)
                ) {
                  Text("◀", fontSize = 12.sp)
                }
                Text(
                  text = String.format(Locale.US, "%02d", selectedMinute),
                  fontWeight = FontWeight.Bold,
                  fontSize = 22.sp,
                  color = MaterialTheme.colorScheme.onPrimaryContainer,
                  modifier = Modifier.padding(horizontal = 10.dp)
                )
                IconButton(
                  onClick = {
                    selectedMinute = (selectedMinute + 15) % 60
                  },
                  modifier = Modifier.size(32.dp)
                ) {
                  Text("▶", fontSize = 12.sp)
                }
              }
            }
          }
        }
      }
    },
    confirmButton = {
      Button(
        onClick = { onConfirm(selectedHour, selectedMinute) },
        shape = RoundedCornerShape(10.dp)
      ) {
        Text("Mirkaneessi", fontWeight = FontWeight.Bold)
      }
    },
    dismissButton = {
      TextButton(onClick = onDismiss) {
        Text("Dhiisi")
      }
    }
  )
}

fun formatTimeString(hour: Int, minute: Int): String {
  val period = if (hour < 12) "AM" else "PM"
  val displayHour = when {
    hour == 0 -> 12
    hour > 12 -> hour - 12
    else -> hour
  }
  return String.format(Locale.US, "%02d:%02d (%02d:%02d %s)", hour, minute, displayHour, minute, period)
}
