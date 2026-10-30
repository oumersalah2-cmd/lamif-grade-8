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
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.LockOpen
import androidx.compose.material.icons.filled.VerifiedUser
import androidx.compose.material3.AlertDialog
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
import androidx.compose.material3.TextButton
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
  onOpenActivation: () -> Unit = {},
  themeMode: AppThemeMode = AppThemeMode.SYSTEM,
  onQuickToggleTheme: () -> Unit = {},
  modifier: Modifier = Modifier
) {
  val state by viewModel.uiState.collectAsState()
  var showLockedDialog by remember { mutableStateOf(false) }

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
          // 2. Offline Activation Banner
      item {
        Card(
          shape = RoundedCornerShape(16.dp),
          colors = CardDefaults.cardColors(
            containerColor = if (state.isActivated) {
              Color(0xFFDCFCE7)
            } else {
              Color(0xFFFEF3C7)
            }
          ),
          modifier = Modifier
            .fillMaxWidth()
            .clickable { onOpenActivation() }
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
                imageVector = if (state.isActivated) Icons.Default.VerifiedUser else Icons.Default.Lock,
                contentDescription = null,
                tint = if (state.isActivated) Color(0xFF15803D) else Color(0xFFD97706),
                modifier = Modifier.size(24.dp)
              )
              Spacer(modifier = Modifier.width(10.dp))
              Column {
                Text(
                  text = if (state.isActivated) {
                    "Moobaayilli Keessan Bantameera 🌟"
                  } else {
                    "Qormaata Hunda Banadhaa (Offline Activation)"
                  },
                  fontWeight = FontWeight.SemiBold,
                  fontSize = 13.sp,
                  color = if (state.isActivated) Color(0xFF15803D) else Color(0xFF92400E)
                )
                Text(
                  text = if (state.isActivated) {
                    "Qormaata ministirii hunda daangaa malee fayyadamaa"
                  } else {
                    "Shaakalli bilisa; qormaata mock ministirii guutuu banachuuf tuqaa"
                  },
                  fontSize = 11.sp,
                  color = if (state.isActivated) Color(0xFF166534) else Color(0xFFB45309)
                )
              }
            }

            if (!state.isActivated) {
              Button(
                onClick = onOpenActivation,
                shape = RoundedCornerShape(8.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFD97706)),
                contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp)
              ) {
                Text("Banadhu", fontSize = 11.sp, fontWeight = FontWeight.Bold)
              }
            }
          }
        }
      }    }

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
          isActivated = state.isActivated,
          onStartExam = onStartExam,
          onLockedClick = { showLockedDialog = true }
        )
      }
    }

    if (showLockedDialog) {
      AlertDialog(
        onDismissRequest = { showLockedDialog = false },
        title = {
          Text("Qormaata Ministirii Guutuu (Full Mock Exam)", fontWeight = FontWeight.Bold, fontSize = 16.sp)
        },
        text = {
          Text(
            "Shaakalli daangaa malee bilisa. Qormaata ministirii naannoo guutuu banachuuf koodii mirkaneessaa galchaa.",
            fontSize = 13.sp
          )
        },
        confirmButton = {
          Button(
            onClick = {
              showLockedDialog = false
              onOpenActivation()
            }
          ) {
            Text("Koodii Galchi (Activate)")
          }
        },
        dismissButton = {
          TextButton(onClick = { showLockedDialog = false }) {
            Text("Hafte")
          }
        }
      )
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
  isActivated: Boolean,
  onStartExam: (Subject, ExamMode) -> Unit,
  onLockedClick: () -> Unit
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
        // Free Practice Button (Always available without activation)
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
            text = "Shaakala (Bilisa)",
            fontSize = 12.sp,
            fontWeight = FontWeight.SemiBold
          )
        }

        // Full Ministry Exam (Locked unless activated)
        Button(
          onClick = {
            if (isActivated) {
              onStartExam(subject, ExamMode.MOCK_MINISTRY)
            } else {
              onLockedClick()
            }
          },
          modifier = Modifier
            .weight(1f)
            .testTag("exam_btn_${subject.id}"),
          shape = RoundedCornerShape(10.dp),
          colors = ButtonDefaults.buttonColors(
            containerColor = if (isActivated) subject.accentColor else MaterialTheme.colorScheme.surfaceVariant,
            contentColor = if (isActivated) Color.White else MaterialTheme.colorScheme.onSurfaceVariant
          ),
          contentPadding = PaddingValues(vertical = 8.dp)
        ) {
          Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
              imageVector = if (isActivated) Icons.Default.PlayArrow else Icons.Default.Lock,
              contentDescription = null,
              modifier = Modifier.size(16.dp)
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text(
              text = if (isActivated) "Qormaata Jalqabi" else "Cufameera",
              fontSize = 12.sp,
              fontWeight = FontWeight.Bold
            )
          }
        }
      }
    }
  }
}
