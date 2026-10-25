package com.example.features.home

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
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
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.CloudDone
import androidx.compose.material.icons.filled.CloudUpload
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.MenuBook
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.School
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material.icons.filled.WorkspacePremium
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.Subject
import com.example.features.exams.ExamMode

import com.example.ui.theme.AppThemeMode
import com.example.ui.theme.ThemeQuickToggleButton

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
  viewModel: HomeViewModel,
  onStartExam: (Subject, ExamMode) -> Unit,
  onOpenStudyNotes: () -> Unit,
  onOpenProfile: () -> Unit,
  onReviewMistakes: () -> Unit,
  onOpenSchedule: () -> Unit,
  themeMode: AppThemeMode = AppThemeMode.SYSTEM,
  onQuickToggleTheme: () -> Unit = {},
  modifier: Modifier = Modifier
) {
  val state by viewModel.uiState.collectAsState()

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
              modifier = Modifier
                .size(38.dp)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.primaryContainer),
              contentAlignment = Alignment.Center
            ) {
              Icon(
                imageVector = Icons.Default.School,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(22.dp)
              )
            }
            Spacer(modifier = Modifier.width(10.dp))
            Column {
              Text(
                text = "Lamif Kutaa 8",
                fontWeight = FontWeight.Bold,
                fontSize = 18.sp,
                color = MaterialTheme.colorScheme.onSurface
              )
              Text(
                text = "Qophii Qormaata Naannoo",
                fontSize = 11.sp,
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Medium
              )
            }
          }
        },
        actions = {
          ThemeQuickToggleButton(
            currentMode = themeMode,
            onToggle = onQuickToggleTheme
          )
          IconButton(
            onClick = onOpenProfile,
            modifier = Modifier.testTag("profile_button")
          ) {
            Icon(
              imageVector = Icons.Default.Person,
              contentDescription = "Profile Barataa",
              tint = MaterialTheme.colorScheme.primary
            )
          }
        },
        colors = TopAppBarDefaults.topAppBarColors(
          containerColor = MaterialTheme.colorScheme.surface
        )
      )
    },
    modifier = modifier
  ) { padding ->
    LazyColumn(
      modifier = Modifier
        .fillMaxSize()
        .padding(padding),
      contentPadding = PaddingValues(16.dp),
      verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
      // 1. Student Greeting & Motivation Banner
      item {
        Card(
          shape = RoundedCornerShape(20.dp),
          colors = CardDefaults.cardColors(containerColor = Color.Transparent),
          modifier = Modifier.fillMaxWidth()
        ) {
          Box(
            modifier = Modifier
              .background(
                Brush.horizontalGradient(
                  colors = listOf(
                    MaterialTheme.colorScheme.primary,
                    MaterialTheme.colorScheme.primary.copy(alpha = 0.85f)
                  )
                )
              )
              .padding(18.dp)
          ) {
            Column {
              Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
              ) {
                Column {
                  Text(
                    text = "Baga Nagaan Dhufte! 👋",
                    color = Color.White.copy(alpha = 0.85f),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium
                  )
                  Text(
                    text = state.studentName,
                    color = Color.White,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold
                  )
                }

                Surface(
                  shape = RoundedCornerShape(12.dp),
                  color = Color.White.copy(alpha = 0.2f)
                ) {
                  Row(
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Icon(
                      imageVector = Icons.Default.WorkspacePremium,
                      contentDescription = null,
                      tint = Color(0xFFFFD54F),
                      modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                      text = "${state.streakDays} Guyyaa",
                      color = Color.White,
                      fontSize = 12.sp,
                      fontWeight = FontWeight.Bold
                    )
                  }
                }
              }

              Spacer(modifier = Modifier.height(12.dp))
              Text(
                text = "${state.schoolName} • ${state.zoneName}",
                color = Color.White.copy(alpha = 0.9f),
                fontSize = 12.sp
              )

              Spacer(modifier = Modifier.height(14.dp))
              // Stat Counters
              Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
              ) {
                StatBadge(
                  label = "Qormaata",
                  value = "${state.totalExamsTaken}",
                  containerColor = Color.White.copy(alpha = 0.15f)
                )
                StatBadge(
                  label = "Giddu-galeessa",
                  value = "${state.averageScore}%",
                  containerColor = Color.White.copy(alpha = 0.15f)
                )
                StatBadge(
                  label = "Galma Qabxii",
                  value = "${state.targetScore}%",
                  containerColor = Color.White.copy(alpha = 0.15f)
                )
              }
            }
          }
        }
      }

      // 2. Offline Sync Banner
      item {
        Card(
          shape = RoundedCornerShape(16.dp),
          colors = CardDefaults.cardColors(
            containerColor = if (state.pendingSyncCount > 0) {
              MaterialTheme.colorScheme.secondaryContainer
            } else {
              MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f)
            }
          ),
          modifier = Modifier.fillMaxWidth()
        ) {
          Row(
            modifier = Modifier
              .fillMaxWidth()
              .padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
          ) {
            Row(
              verticalAlignment = Alignment.CenterVertically,
              modifier = Modifier.weight(1f)
            ) {
              Icon(
                imageVector = if (state.pendingSyncCount > 0) Icons.Default.CloudUpload else Icons.Default.CloudDone,
                contentDescription = null,
                tint = if (state.pendingSyncCount > 0) MaterialTheme.colorScheme.secondary else MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(24.dp)
              )
              Spacer(modifier = Modifier.width(10.dp))
              Column {
                Text(
                  text = if (state.pendingSyncCount > 0) {
                    "Qabxiiwwan Kuufaman: ${state.pendingSyncCount}"
                  } else {
                    "Daataan Guutummaatti Qindaa'eera (Synced)"
                  },
                  fontWeight = FontWeight.SemiBold,
                  fontSize = 13.sp,
                  color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                  text = if (state.pendingSyncCount > 0) {
                    "Offline qormaata fudhatte; yeroo intarneetii argattu ergi"
                  } else {
                    "Offline-first: Intarneetii malee qormaata hunda hojjedhu"
                  },
                  fontSize = 11.sp,
                  color = MaterialTheme.colorScheme.onSurfaceVariant
                )
              }
            }

            if (state.pendingSyncCount > 0) {
              Button(
                onClick = { viewModel.triggerSync() },
                enabled = !state.isSyncing,
                modifier = Modifier.testTag("sync_now_button"),
                colors = ButtonDefaults.buttonColors(
                  containerColor = MaterialTheme.colorScheme.secondary
                ),
                contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
              ) {
                if (state.isSyncing) {
                  CircularProgressIndicator(
                    modifier = Modifier.size(16.dp),
                    strokeWidth = 2.dp,
                    color = Color.White
                  )
                } else {
                  Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                      imageVector = Icons.Default.Refresh,
                      contentDescription = null,
                      modifier = Modifier.size(14.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text("Qindeessi", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                  }
                }
              }
            }
          }
        }
      }

      // 3. Quick Action Tiles
      item {
        Text(
          text = "Filannoo Qophii Ariifachiisaa",
          fontSize = 15.sp,
          fontWeight = FontWeight.Bold,
          color = MaterialTheme.colorScheme.onSurface
        )

        Spacer(modifier = Modifier.height(8.dp))

        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
          QuickActionCard(
            title = "Mock Ministry",
            subtitle = "Qormaata Sa'aatii",
            icon = Icons.Default.DateRange,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.weight(1f),
            onClick = { onStartExam(Subject.AFAAN_OROMOO, ExamMode.MOCK_MINISTRY) }
          )

          QuickActionCard(
            title = "Dogoggora Kee",
            subtitle = "Koreeffama Gaaffii",
            icon = Icons.Default.Warning,
            color = Color(0xFFDC2626),
            modifier = Modifier.weight(1f),
            onClick = onReviewMistakes
          )
        }

        Spacer(modifier = Modifier.height(10.dp))

        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
          QuickActionCard(
            title = "Sagantaa",
            subtitle = "Qo'annoo Guyyaa",
            icon = Icons.Default.CalendarMonth,
            color = Color(0xFF0D9488),
            modifier = Modifier.weight(1f),
            onClick = onOpenSchedule
          )

          QuickActionCard(
            title = "Yaadannoo",
            subtitle = "Foormulaawwan",
            icon = Icons.Default.MenuBook,
            color = Color(0xFFD97706),
            modifier = Modifier.weight(1f),
            onClick = onOpenStudyNotes
          )
        }
      }

      // 4. Subjects Section Header
      item {
        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.SpaceBetween,
          verticalAlignment = Alignment.CenterVertically
        ) {
          Text(
            text = "Gosoota Barnootaa (Subjects)",
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onSurface
          )
          Text(
            text = "Kutaa 8ffaa Naannoo",
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.primary,
            fontWeight = FontWeight.Medium
          )
        }
      }

      // 5. Subject Cards List
      items(Subject.entries) { subject ->
        SubjectCardItem(
          subject = subject,
          onStartExam = onStartExam
        )
      }
    }
  }
}

@Composable
fun StatBadge(
  label: String,
  value: String,
  containerColor: Color
) {
  Surface(
    shape = RoundedCornerShape(12.dp),
    color = containerColor
  ) {
    Column(
      modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp),
      horizontalAlignment = Alignment.CenterHorizontally
    ) {
      Text(
        text = value,
        color = Color.White,
        fontWeight = FontWeight.Bold,
        fontSize = 15.sp
      )
      Text(
        text = label,
        color = Color.White.copy(alpha = 0.8f),
        fontSize = 10.sp
      )
    }
  }
}

@Composable
fun QuickActionCard(
  title: String,
  subtitle: String,
  icon: androidx.compose.ui.graphics.vector.ImageVector,
  color: Color,
  modifier: Modifier = Modifier,
  onClick: () -> Unit
) {
  Card(
    modifier = modifier.clickable { onClick() },
    shape = RoundedCornerShape(14.dp),
    colors = CardDefaults.cardColors(
      containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
    )
  ) {
    Column(
      modifier = Modifier.padding(12.dp),
      horizontalAlignment = Alignment.Start
    ) {
      Box(
        modifier = Modifier
          .size(34.dp)
          .clip(RoundedCornerShape(8.dp))
          .background(color.copy(alpha = 0.15f)),
        contentAlignment = Alignment.Center
      ) {
        Icon(
          imageVector = icon,
          contentDescription = null,
          tint = color,
          modifier = Modifier.size(20.dp)
        )
      }
      Spacer(modifier = Modifier.height(8.dp))
      Text(
        text = title,
        fontWeight = FontWeight.Bold,
        fontSize = 13.sp,
        color = MaterialTheme.colorScheme.onSurface
      )
      Text(
        text = subtitle,
        fontSize = 10.sp,
        color = MaterialTheme.colorScheme.onSurfaceVariant
      )
    }
  }
}

@Composable
fun SubjectCardItem(
  subject: Subject,
  onStartExam: (Subject, ExamMode) -> Unit
) {
  Card(
    shape = RoundedCornerShape(16.dp),
    colors = CardDefaults.cardColors(
      containerColor = MaterialTheme.colorScheme.surface
    ),
    elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
    modifier = Modifier.fillMaxWidth()
  ) {
    Column(modifier = Modifier.padding(16.dp)) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
      ) {
        Box(
          modifier = Modifier
            .size(46.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(subject.accentColor.copy(alpha = 0.12f)),
          contentAlignment = Alignment.Center
        ) {
          Icon(
            imageVector = subject.icon,
            contentDescription = null,
            tint = subject.accentColor,
            modifier = Modifier.size(26.dp)
          )
        }

        Spacer(modifier = Modifier.width(12.dp))

        Column(modifier = Modifier.weight(1f)) {
          Text(
            text = subject.afaanOromoName,
            fontWeight = FontWeight.Bold,
            fontSize = 16.sp,
            color = MaterialTheme.colorScheme.onSurface
          )
          Text(
            text = subject.descriptionOm,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
          )
        }
      }

      Spacer(modifier = Modifier.height(14.dp))

      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
      ) {
        Button(
          onClick = { onStartExam(subject, ExamMode.PRACTICE) },
          modifier = Modifier
            .weight(1f)
            .testTag("practice_btn_${subject.id}"),
          shape = RoundedCornerShape(10.dp),
          colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant,
            contentColor = MaterialTheme.colorScheme.onSurfaceVariant
          ),
          contentPadding = PaddingValues(vertical = 8.dp)
        ) {
          Text(
            text = "Shaakala (Study)",
            fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold
          )
        }

        Button(
          onClick = { onStartExam(subject, ExamMode.MOCK_MINISTRY) },
          modifier = Modifier
            .weight(1f)
            .testTag("exam_btn_${subject.id}"),
          shape = RoundedCornerShape(10.dp),
          colors = ButtonDefaults.buttonColors(
            containerColor = subject.accentColor
          ),
          contentPadding = PaddingValues(vertical = 8.dp)
        ) {
          Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
              imageVector = Icons.Default.PlayArrow,
              contentDescription = null,
              modifier = Modifier.size(16.dp)
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text(
              text = "Qormaata Jalqabi",
              fontSize = 12.sp,
              fontWeight = FontWeight.Bold
            )
          }
        }
      }
    }
  }
}
