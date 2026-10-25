package com.example.features.schedule

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AccessTime
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.RadioButtonUnchecked
import androidx.compose.material.icons.filled.School
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
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
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.local.entities.StudySessionEntity
import com.example.data.model.Subject

import com.example.features.schedule.components.StudyReminderCard

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScheduleScreen(
  viewModel: ScheduleViewModel,
  onNavigateBack: () -> Unit,
  modifier: Modifier = Modifier
) {
  val selectedDay by viewModel.selectedDay.collectAsState()
  val sessions by viewModel.sessionsForSelectedDay.collectAsState()
  val reminderEnabled by viewModel.reminderEnabled.collectAsState()
  val reminderHour by viewModel.reminderHour.collectAsState()
  val reminderMinute by viewModel.reminderMinute.collectAsState()
  val hasPermission by viewModel.hasNotificationPermission.collectAsState()
  var showAddDialog by remember { mutableStateOf(false) }

  val totalSessions = sessions.size
  val completedCount = sessions.count { it.isCompleted }
  val progress = if (totalSessions > 0) completedCount.toFloat() / totalSessions.toFloat() else 0f

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Column {
            Text(
              text = "Sagantaa Qo'annoo",
              fontWeight = FontWeight.Bold,
              fontSize = 17.sp
            )
            Text(
              text = "Daily Study Planner (Offline)",
              fontSize = 11.sp,
              color = MaterialTheme.colorScheme.onSurfaceVariant
            )
          }
        },
        navigationIcon = {
          IconButton(onClick = onNavigateBack, modifier = Modifier.testTag("schedule_back_btn")) {
            Icon(imageVector = Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Deebi'i")
          }
        },
        actions = {
          IconButton(
            onClick = { showAddDialog = true },
            modifier = Modifier.testTag("add_session_btn")
          ) {
            Icon(
              imageVector = Icons.Default.Add,
              contentDescription = "Sagantaa Dabali",
              tint = MaterialTheme.colorScheme.primary
            )
          }
        },
        colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.surface)
      )
    },
    floatingActionButton = {
      FloatingActionButton(
        onClick = { showAddDialog = true },
        containerColor = MaterialTheme.colorScheme.primary,
        contentColor = Color.White,
        modifier = Modifier.testTag("fab_add_session")
      ) {
        Icon(imageVector = Icons.Default.Add, contentDescription = "Dabali")
      }
    },
    modifier = modifier
  ) { padding ->
    Column(
      modifier = Modifier
        .fillMaxSize()
        .padding(padding)
    ) {
      // 1. Day of Week Horizontal Selector
      LazyRow(
        modifier = Modifier
          .fillMaxWidth()
          .background(MaterialTheme.colorScheme.surface)
          .padding(horizontal = 16.dp, vertical = 10.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
      ) {
        items(DayOfWeekOm.entries) { day ->
          val isSelected = day == selectedDay
          FilterChip(
            selected = isSelected,
            onClick = { viewModel.selectDay(day) },
            label = {
              Text(
                text = day.shortNameOm,
                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                fontSize = 13.sp
              )
            },
            shape = RoundedCornerShape(12.dp)
          )
        }
      }

      LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
      ) {
        // 2. Daily Study Progress Banner
        item {
          Card(
            shape = RoundedCornerShape(18.dp),
            colors = CardDefaults.cardColors(
              containerColor = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f)
            ),
            modifier = Modifier.fillMaxWidth()
          ) {
            Column(modifier = Modifier.padding(16.dp)) {
              Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
              ) {
                Column {
                  Text(
                    text = selectedDay.fullNameOm,
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                  )
                  Text(
                    text = if (totalSessions > 0) "$completedCount/$totalSessions Qo'annoo xumurameera" else "Sagantaan hin qophoofne",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f)
                  )
                }

                Surface(
                  shape = CircleShape,
                  color = MaterialTheme.colorScheme.primary
                ) {
                  Text(
                    text = "${(progress * 100).toInt()}%",
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 13.sp,
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                  )
                }
              }

              Spacer(modifier = Modifier.height(12.dp))

              LinearProgressIndicator(
                progress = { progress },
                modifier = Modifier
                  .fillMaxWidth()
                  .height(8.dp)
                  .clip(RoundedCornerShape(4.dp)),
                color = MaterialTheme.colorScheme.primary,
                trackColor = Color.White.copy(alpha = 0.4f)
              )
            }
          }
        }

        // 3. Daily Study Reminder Notification Card
        item {
          StudyReminderCard(
            reminderEnabled = reminderEnabled,
            reminderHour = reminderHour,
            reminderMinute = reminderMinute,
            hasPermission = hasPermission,
            onToggleEnabled = { viewModel.setReminderEnabled(it) },
            onTimeChanged = { hour, minute -> viewModel.setReminderTime(hour, minute) },
            onSendTestNotification = { viewModel.sendTestReminder() },
            onPermissionRefreshed = { viewModel.refreshPermissionStatus() }
          )
        }

        // 4. Section Title
        item {
          Text(
            text = "Sagantaalee Har'aa (${sessions.size})",
            fontWeight = FontWeight.Bold,
            fontSize = 15.sp,
            color = MaterialTheme.colorScheme.onSurface
          )
        }

        // 4. Empty State or Sessions List
        if (sessions.isEmpty()) {
          item {
            Card(
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 20.dp)
            ) {
              Column(
                modifier = Modifier
                  .fillMaxWidth()
                  .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
              ) {
                Icon(
                  imageVector = Icons.Default.CalendarMonth,
                  contentDescription = null,
                  tint = MaterialTheme.colorScheme.primary,
                  modifier = Modifier.size(48.dp)
                )
                Spacer(modifier = Modifier.height(12.dp))
                Text(
                  text = "Guyyaa kanaaf sagantaan hin jiru",
                  fontWeight = FontWeight.Bold,
                  fontSize = 15.sp
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                  text = "Qo'annoo haaraa galchuuf mallattoo '+' tuqaa.",
                  fontSize = 12.sp,
                  color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(14.dp))
                Button(
                  onClick = { showAddDialog = true },
                  shape = RoundedCornerShape(10.dp)
                ) {
                  Text("Sagantaa Haaraa Dabali")
                }
              }
            }
          }
        } else {
          items(sessions, key = { it.id }) { session ->
            val subject = Subject.fromId(session.subjectId)
            StudySessionCard(
              session = session,
              subject = subject,
              onToggleCompleted = { viewModel.toggleCompleted(session) },
              onDelete = { viewModel.deleteSession(session) }
            )
          }
        }
      }
    }
  }

  // Add Session Dialog
  if (showAddDialog) {
    AddSessionDialog(
      onDismiss = { showAddDialog = false },
      onConfirm = { subject, time, duration, topic ->
        viewModel.addStudySession(subject, time, duration, topic)
        showAddDialog = false
      }
    )
  }
}

@Composable
fun StudySessionCard(
  session: StudySessionEntity,
  subject: Subject,
  onToggleCompleted: () -> Unit,
  onDelete: () -> Unit
) {
  val cardBg by animateColorAsState(
    if (session.isCompleted) MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f)
    else MaterialTheme.colorScheme.surface,
    label = "cardBg"
  )

  Card(
    shape = RoundedCornerShape(16.dp),
    colors = CardDefaults.cardColors(containerColor = cardBg),
    elevation = CardDefaults.cardElevation(defaultElevation = if (session.isCompleted) 0.dp else 1.dp),
    modifier = Modifier.fillMaxWidth()
  ) {
    Row(
      modifier = Modifier
        .fillMaxWidth()
        .padding(14.dp),
      verticalAlignment = Alignment.CenterVertically
    ) {
      // Completed Checkbox Button
      IconButton(
        onClick = onToggleCompleted,
        modifier = Modifier.testTag("check_session_${session.id}")
      ) {
        Icon(
          imageVector = if (session.isCompleted) Icons.Default.CheckCircle else Icons.Default.RadioButtonUnchecked,
          contentDescription = "Xumuri",
          tint = if (session.isCompleted) Color(0xFF16A34A) else MaterialTheme.colorScheme.onSurfaceVariant,
          modifier = Modifier.size(24.dp)
        )
      }

      Spacer(modifier = Modifier.width(4.dp))

      // Subject Icon
      Box(
        modifier = Modifier
          .size(42.dp)
          .clip(RoundedCornerShape(10.dp))
          .background(subject.accentColor.copy(alpha = 0.12f)),
        contentAlignment = Alignment.Center
      ) {
        Icon(
          imageVector = subject.icon,
          contentDescription = null,
          tint = subject.accentColor,
          modifier = Modifier.size(22.dp)
        )
      }

      Spacer(modifier = Modifier.width(12.dp))

      Column(modifier = Modifier.weight(1f)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
          Text(
            text = subject.afaanOromoName,
            fontWeight = FontWeight.Bold,
            fontSize = 14.sp,
            color = if (session.isCompleted) MaterialTheme.colorScheme.onSurfaceVariant else MaterialTheme.colorScheme.onSurface,
            textDecoration = if (session.isCompleted) TextDecoration.LineThrough else TextDecoration.None
          )
          Spacer(modifier = Modifier.width(8.dp))
          Surface(
            shape = RoundedCornerShape(6.dp),
            color = MaterialTheme.colorScheme.surfaceVariant
          ) {
            Text(
              text = "${session.durationMinutes} daqiiqaa",
              fontSize = 10.sp,
              modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
            )
          }
        }

        Spacer(modifier = Modifier.height(2.dp))

        Text(
          text = session.topicFocusOm,
          fontSize = 12.sp,
          color = MaterialTheme.colorScheme.onSurfaceVariant,
          maxLines = 2
        )

        Spacer(modifier = Modifier.height(4.dp))

        Row(verticalAlignment = Alignment.CenterVertically) {
          Icon(
            imageVector = Icons.Default.AccessTime,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.primary,
            modifier = Modifier.size(12.dp)
          )
          Spacer(modifier = Modifier.width(4.dp))
          Text(
            text = session.startTime,
            fontSize = 11.sp,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.primary
          )
        }
      }

      IconButton(onClick = onDelete) {
        Icon(
          imageVector = Icons.Default.Delete,
          contentDescription = "Haqi",
          tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f),
          modifier = Modifier.size(18.dp)
        )
      }
    }
  }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddSessionDialog(
  onDismiss: () -> Unit,
  onConfirm: (subject: Subject, time: String, duration: Int, topic: String) -> Unit
) {
  var selectedSubject by remember { mutableStateOf(Subject.AFAAN_OROMOO) }
  var subjectMenuExpanded by remember { mutableStateOf(false) }
  var timeText by remember { mutableStateOf("04:30 PM") }
  var selectedDuration by remember { mutableIntStateOf(45) }
  var topicText by remember { mutableStateOf("") }

  val durations = listOf(30, 45, 60, 90)

  AlertDialog(
    onDismissRequest = onDismiss,
    title = {
      Text(text = "Sagantaa Haaraa Dabali", fontWeight = FontWeight.Bold, fontSize = 17.sp)
    },
    text = {
      Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(10.dp)
      ) {
        // Subject Selector
        ExposedDropdownMenuBox(
          expanded = subjectMenuExpanded,
          onExpandedChange = { subjectMenuExpanded = !subjectMenuExpanded }
        ) {
          OutlinedTextField(
            value = selectedSubject.afaanOromoName,
            onValueChange = {},
            readOnly = true,
            label = { Text("Gosa Barnootaa") },
            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = subjectMenuExpanded) },
            modifier = Modifier
              .menuAnchor()
              .fillMaxWidth(),
            shape = RoundedCornerShape(10.dp)
          )
          ExposedDropdownMenu(
            expanded = subjectMenuExpanded,
            onDismissRequest = { subjectMenuExpanded = false }
          ) {
            Subject.entries.forEach { subj ->
              DropdownMenuItem(
                text = { Text(subj.afaanOromoName) },
                onClick = {
                  selectedSubject = subj
                  subjectMenuExpanded = false
                }
              )
            }
          }
        }

        // Time Field
        OutlinedTextField(
          value = timeText,
          onValueChange = { timeText = it },
          label = { Text("Sa'aatii (fkn: 04:30 PM)") },
          modifier = Modifier.fillMaxWidth(),
          singleLine = true,
          shape = RoundedCornerShape(10.dp)
        )

        // Duration Chips
        Text(text = "Turtii (Daqiiqaa):", fontSize = 12.sp, fontWeight = FontWeight.SemiBold)
        Row(
          horizontalArrangement = Arrangement.spacedBy(6.dp),
          modifier = Modifier.fillMaxWidth()
        ) {
          durations.forEach { dur ->
            FilterChip(
              selected = selectedDuration == dur,
              onClick = { selectedDuration = dur },
              label = { Text("$dur m", fontSize = 11.sp) }
            )
          }
        }

        // Topic field
        OutlinedTextField(
          value = topicText,
          onValueChange = { topicText = it },
          label = { Text("Mata duree / Topic (Filannoo)") },
          placeholder = { Text("fkn: Boqonnaa 3 irra deebi'uu") },
          modifier = Modifier.fillMaxWidth(),
          shape = RoundedCornerShape(10.dp)
        )
      }
    },
    confirmButton = {
      Button(
        onClick = {
          onConfirm(selectedSubject, timeText, selectedDuration, topicText)
        },
        modifier = Modifier.testTag("confirm_add_session_btn")
      ) {
        Text("Dabali")
      }
    },
    dismissButton = {
      TextButton(onClick = onDismiss) {
        Text("Haqi")
      }
    }
  )
}
