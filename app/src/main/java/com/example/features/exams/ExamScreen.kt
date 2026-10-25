package com.example.features.exams

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.BookmarkBorder
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Flag
import androidx.compose.material.icons.filled.GridOn
import androidx.compose.material.icons.filled.OutlinedFlag
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.local.entities.QuestionEntity
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun ExamScreen(
  viewModel: ExamViewModel,
  onExamFinished: () -> Unit,
  onNavigateBack: () -> Unit,
  modifier: Modifier = Modifier
) {
  val state by viewModel.uiState.collectAsState()
  var showPaletteSheet by remember { mutableStateOf(false) }
  var showConfirmSubmitDialog by remember { mutableStateOf(false) }
  var showExitConfirmDialog by remember { mutableStateOf(false) }

  BackHandler {
    if (state.isFinished) {
      onNavigateBack()
    } else {
      showExitConfirmDialog = true
    }
  }

  // If exam has completed, inform caller
  if (state.isFinished && state.completedAttempt != null) {
    onExamFinished()
    return
  }

  val currentQuestion = viewModel.currentQuestion
  val questionsCount = state.questions.size
  val currentIndex = state.currentQuestionIndex

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Column {
            Text(
              text = state.subject.afaanOromoName,
              fontSize = 16.sp,
              fontWeight = FontWeight.Bold
            )
            Text(
              text = if (state.mode == ExamMode.MOCK_MINISTRY) "Qormaata Mock (Timed)" else "Shaakala Qajeelchaa (Practice)",
              fontSize = 11.sp,
              color = MaterialTheme.colorScheme.onSurfaceVariant
            )
          }
        },
        navigationIcon = {
          IconButton(
            onClick = { showExitConfirmDialog = true },
            modifier = Modifier.testTag("exit_exam_button")
          ) {
            Icon(
              imageVector = Icons.Default.Close,
              contentDescription = "Bahi"
            )
          }
        },
        actions = {
          // Timer Badge
          val minutes = state.remainingSeconds / 60
          val seconds = state.remainingSeconds % 60
          val timerColor = when {
            state.remainingSeconds < 120 -> Color(0xFFDC2626) // Red warning
            state.remainingSeconds < 300 -> Color(0xFFD97706) // Amber warning
            else -> MaterialTheme.colorScheme.primary
          }

          Surface(
            shape = RoundedCornerShape(20.dp),
            color = timerColor.copy(alpha = 0.12f),
            modifier = Modifier.padding(end = 4.dp)
          ) {
            Row(
              modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
              verticalAlignment = Alignment.CenterVertically
            ) {
              Icon(
                imageVector = Icons.Default.Timer,
                contentDescription = null,
                tint = timerColor,
                modifier = Modifier.size(14.dp)
              )
              Spacer(modifier = Modifier.width(4.dp))
              Text(
                text = String.format(Locale.getDefault(), "%02d:%02d", minutes, seconds),
                fontWeight = FontWeight.Bold,
                fontSize = 13.sp,
                color = timerColor
              )
            }
          }

          // Bookmark Toggle
          IconButton(
            onClick = { viewModel.toggleBookmarkCurrentQuestion() },
            modifier = Modifier.testTag("bookmark_button")
          ) {
            val isBookmarked = currentQuestion != null && state.bookmarkedQuestions.contains(currentQuestion.id)
            Icon(
              imageVector = if (isBookmarked) Icons.Default.Bookmark else Icons.Default.BookmarkBorder,
              contentDescription = "Qabadhu (Bookmark)",
              tint = if (isBookmarked) Color(0xFFD97706) else MaterialTheme.colorScheme.onSurfaceVariant
            )
          }

          // Flag Question
          IconButton(
            onClick = { viewModel.toggleFlagCurrentQuestion() },
            modifier = Modifier.testTag("flag_button")
          ) {
            val isFlagged = currentQuestion != null && state.flaggedQuestions.contains(currentQuestion.id)
            Icon(
              imageVector = if (isFlagged) Icons.Default.Flag else Icons.Default.OutlinedFlag,
              contentDescription = "Mallatteessi (Flag)",
              tint = if (isFlagged) Color(0xFFDC2626) else MaterialTheme.colorScheme.onSurfaceVariant
            )
          }
        },
        colors = TopAppBarDefaults.topAppBarColors(
          containerColor = MaterialTheme.colorScheme.surface
        )
      )
    },
    bottomBar = {
      Surface(
        tonalElevation = 8.dp,
        shadowElevation = 8.dp,
        color = MaterialTheme.colorScheme.surface
      ) {
        Row(
          modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 10.dp),
          horizontalArrangement = Arrangement.SpaceBetween,
          verticalAlignment = Alignment.CenterVertically
        ) {
          // Previous button
          OutlinedButton(
            onClick = { viewModel.previousQuestion() },
            enabled = currentIndex > 0,
            modifier = Modifier.testTag("prev_question_btn"),
            shape = RoundedCornerShape(10.dp),
            contentPadding = PaddingValues(horizontal = 12.dp, vertical = 8.dp)
          ) {
            Icon(
              imageVector = Icons.AutoMirrored.Filled.ArrowBack,
              contentDescription = null,
              modifier = Modifier.size(16.dp)
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text("Duraa", fontSize = 12.sp)
          }

          // Question Palette Grid Toggle
          Button(
            onClick = { showPaletteSheet = true },
            modifier = Modifier.testTag("palette_toggle_btn"),
            colors = ButtonDefaults.buttonColors(
              containerColor = MaterialTheme.colorScheme.surfaceVariant,
              contentColor = MaterialTheme.colorScheme.onSurfaceVariant
            ),
            shape = RoundedCornerShape(10.dp),
            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 8.dp)
          ) {
            Icon(
              imageVector = Icons.Default.GridOn,
              contentDescription = null,
              modifier = Modifier.size(16.dp)
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text("${currentIndex + 1}/$questionsCount", fontSize = 12.sp, fontWeight = FontWeight.Bold)
          }

          // Next or Submit button
          if (currentIndex < questionsCount - 1) {
            Button(
              onClick = { viewModel.nextQuestion() },
              modifier = Modifier.testTag("next_question_btn"),
              shape = RoundedCornerShape(10.dp),
              contentPadding = PaddingValues(horizontal = 12.dp, vertical = 8.dp)
            ) {
              Text("Itti Aani", fontSize = 12.sp)
              Spacer(modifier = Modifier.width(4.dp))
              Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                contentDescription = null,
                modifier = Modifier.size(16.dp)
              )
            }
          } else {
            Button(
              onClick = { showConfirmSubmitDialog = true },
              modifier = Modifier.testTag("submit_exam_btn"),
              colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.primary
              ),
              shape = RoundedCornerShape(10.dp),
              contentPadding = PaddingValues(horizontal = 14.dp, vertical = 8.dp)
            ) {
              Icon(
                imageVector = Icons.Default.CheckCircle,
                contentDescription = null,
                modifier = Modifier.size(16.dp)
              )
              Spacer(modifier = Modifier.width(4.dp))
              Text("Xumuri", fontSize = 12.sp, fontWeight = FontWeight.Bold)
            }
          }
        }
      }
    },
    modifier = modifier
  ) { padding ->
    Column(
      modifier = Modifier
        .fillMaxSize()
        .padding(padding)
    ) {
      // Progress Bar
      val progress = if (questionsCount > 0) (currentIndex + 1).toFloat() / questionsCount.toFloat() else 0f
      LinearProgressIndicator(
        progress = { progress },
        modifier = Modifier.fillMaxWidth(),
        color = MaterialTheme.colorScheme.primary,
        trackColor = MaterialTheme.colorScheme.surfaceVariant
      )

      if (currentQuestion == null) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
          Text("Gaaffiin hin argamne.", color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
      } else {
        LazyColumn(
          modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
          verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
          // Question Header Tags
          item {
            Row(
              modifier = Modifier.fillMaxWidth(),
              horizontalArrangement = Arrangement.SpaceBetween,
              verticalAlignment = Alignment.CenterVertically
            ) {
              Surface(
                shape = RoundedCornerShape(8.dp),
                color = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.6f)
              ) {
                Text(
                  text = currentQuestion.topicOm,
                  fontSize = 11.sp,
                  fontWeight = FontWeight.SemiBold,
                  color = MaterialTheme.colorScheme.primary,
                  modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                )
              }

              Surface(
                shape = RoundedCornerShape(8.dp),
                color = MaterialTheme.colorScheme.surfaceVariant
              ) {
                Text(
                  text = currentQuestion.examYear,
                  fontSize = 11.sp,
                  fontWeight = FontWeight.Medium,
                  color = MaterialTheme.colorScheme.onSurfaceVariant,
                  modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                )
              }
            }
          }

          // Question Prompt Card
          item {
            Card(
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surface
              ),
              elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
              modifier = Modifier.fillMaxWidth()
            ) {
              Column(modifier = Modifier.padding(18.dp)) {
                Text(
                  text = "Gaaffii ${currentIndex + 1}",
                  fontSize = 12.sp,
                  fontWeight = FontWeight.Bold,
                  color = MaterialTheme.colorScheme.primary
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                  text = currentQuestion.questionTextOm,
                  fontSize = 16.sp,
                  fontWeight = FontWeight.Medium,
                  lineHeight = 23.sp,
                  color = MaterialTheme.colorScheme.onSurface
                )
              }
            }
          }

          // 4 Options
          val options = listOf(
            currentQuestion.optionA,
            currentQuestion.optionB,
            currentQuestion.optionC,
            currentQuestion.optionD
          )
          val optionLetters = listOf("A", "B", "C", "D")
          val selectedOption = state.selectedAnswers[currentQuestion.id]

          items(options.size) { idx ->
            val isSelected = selectedOption == idx
            val isPractice = state.mode == ExamMode.PRACTICE
            val isRevealed = isPractice && selectedOption != null
            val isCorrectOption = idx == currentQuestion.correctOptionIndex

            val borderColor = when {
              isRevealed && isCorrectOption -> Color(0xFF16A34A) // Green
              isRevealed && isSelected && !isCorrectOption -> Color(0xFFDC2626) // Red
              isSelected -> MaterialTheme.colorScheme.primary
              else -> MaterialTheme.colorScheme.outline.copy(alpha = 0.4f)
            }

            val containerColor = when {
              isRevealed && isCorrectOption -> Color(0xFF16A34A).copy(alpha = 0.08f)
              isRevealed && isSelected && !isCorrectOption -> Color(0xFFDC2626).copy(alpha = 0.08f)
              isSelected -> MaterialTheme.colorScheme.primary.copy(alpha = 0.06f)
              else -> MaterialTheme.colorScheme.surface
            }

            Card(
              modifier = Modifier
                .fillMaxWidth()
                .clickable { viewModel.selectOption(idx) }
                .testTag("option_${optionLetters[idx]}"),
              shape = RoundedCornerShape(14.dp),
              colors = CardDefaults.cardColors(containerColor = containerColor),
              border = BorderStroke(if (isSelected || (isRevealed && isCorrectOption)) 2.dp else 1.dp, borderColor)
            ) {
              Row(
                modifier = Modifier
                  .fillMaxWidth()
                  .padding(14.dp),
                verticalAlignment = Alignment.CenterVertically
              ) {
                // Letter Badge
                Box(
                  modifier = Modifier
                    .size(34.dp)
                    .clip(CircleShape)
                    .background(
                      if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.surfaceVariant
                    ),
                  contentAlignment = Alignment.Center
                ) {
                  Text(
                    text = optionLetters[idx],
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    color = if (isSelected) Color.White else MaterialTheme.colorScheme.onSurfaceVariant
                  )
                }

                Spacer(modifier = Modifier.width(12.dp))

                Text(
                  text = options[idx],
                  fontSize = 15.sp,
                  color = MaterialTheme.colorScheme.onSurface,
                  modifier = Modifier.weight(1f)
                )

                if (isRevealed) {
                  if (isCorrectOption) {
                    Icon(
                      imageVector = Icons.Default.CheckCircle,
                      contentDescription = null,
                      tint = Color(0xFF16A34A),
                      modifier = Modifier.size(20.dp)
                    )
                  } else if (isSelected) {
                    Icon(
                      imageVector = Icons.Default.Close,
                      contentDescription = null,
                      tint = Color(0xFFDC2626),
                      modifier = Modifier.size(20.dp)
                    )
                  }
                }
              }
            }
          }

          // Practice Mode Explanation Box
          if (state.mode == ExamMode.PRACTICE && selectedOption != null) {
            item {
              val isCorrect = selectedOption == currentQuestion.correctOptionIndex
              Card(
                shape = RoundedCornerShape(14.dp),
                colors = CardDefaults.cardColors(
                  containerColor = if (isCorrect) Color(0xFFD4EDDA) else Color(0xFFFEE2E2)
                ),
                modifier = Modifier.fillMaxWidth()
              ) {
                Column(modifier = Modifier.padding(14.dp)) {
                  Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                      imageVector = if (isCorrect) Icons.Default.CheckCircle else Icons.Default.Close,
                      contentDescription = null,
                      tint = if (isCorrect) Color(0xFF155D27) else Color(0xFF991B1B),
                      modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                      text = if (isCorrect) "Sirrii dha! (Correct)" else "Dogoggora! (Incorrect)",
                      fontWeight = FontWeight.Bold,
                      fontSize = 13.sp,
                      color = if (isCorrect) Color(0xFF155D27) else Color(0xFF991B1B)
                    )
                  }

                  Spacer(modifier = Modifier.height(6.dp))
                  Text(
                    text = "Ibsa Deebii (Rationale):",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface
                  )
                  Text(
                    text = currentQuestion.explanationOm,
                    fontSize = 13.sp,
                    lineHeight = 18.sp,
                    color = MaterialTheme.colorScheme.onSurface
                  )
                }
              }
            }
          }
        }
      }
    }
  }

  // Question Palette Bottom Sheet
  if (showPaletteSheet) {
    ModalBottomSheet(
      onDismissRequest = { showPaletteSheet = false },
      sheetState = rememberModalBottomSheetState()
    ) {
      Column(
        modifier = Modifier
          .fillMaxWidth()
          .padding(20.dp)
      ) {
        Text(
          text = "Tarree Gaaffilee (Question Navigator)",
          fontWeight = FontWeight.Bold,
          fontSize = 16.sp
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(
          text = "Gaaffii tokko irraa gara kaaniitti ariitiin darbuuf tuqi",
          fontSize = 12.sp,
          color = MaterialTheme.colorScheme.onSurfaceVariant
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Legend
        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.SpaceBetween
        ) {
          LegendChip(label = "Deebifame", color = Color(0xFF16A34A))
          LegendChip(label = "Mallatteeffame", color = Color(0xFFDC2626))
          LegendChip(label = "Kan Ammaa", color = MaterialTheme.colorScheme.primary)
          LegendChip(label = "Hafte", color = MaterialTheme.colorScheme.surfaceVariant)
        }

        Spacer(modifier = Modifier.height(18.dp))

        FlowRow(
          horizontalArrangement = Arrangement.spacedBy(8.dp),
          verticalArrangement = Arrangement.spacedBy(8.dp),
          modifier = Modifier.fillMaxWidth()
        ) {
          state.questions.forEachIndexed { index, q ->
            val isAnswered = state.selectedAnswers.containsKey(q.id)
            val isFlagged = state.flaggedQuestions.contains(q.id)
            val isCurrent = index == state.currentQuestionIndex

            val chipBg = when {
              isCurrent -> MaterialTheme.colorScheme.primary
              isFlagged -> Color(0xFFDC2626)
              isAnswered -> Color(0xFF16A34A)
              else -> MaterialTheme.colorScheme.surfaceVariant
            }

            val textColor = when {
              isCurrent || isFlagged || isAnswered -> Color.White
              else -> MaterialTheme.colorScheme.onSurfaceVariant
            }

            Box(
              modifier = Modifier
                .size(42.dp)
                .clip(CircleShape)
                .background(chipBg)
                .clickable {
                  viewModel.jumpToQuestion(index)
                  showPaletteSheet = false
                },
              contentAlignment = Alignment.Center
            ) {
              Text(
                text = "${index + 1}",
                fontWeight = FontWeight.Bold,
                fontSize = 13.sp,
                color = textColor
              )
            }
          }
        }

        Spacer(modifier = Modifier.height(24.dp))
      }
    }
  }

  // Submit Confirmation Dialog
  if (showConfirmSubmitDialog) {
    val answeredCount = state.selectedAnswers.size
    val unansweredCount = questionsCount - answeredCount

    AlertDialog(
      onDismissRequest = { showConfirmSubmitDialog = false },
      title = {
        Text("Qormaata Xumuruu Barbaaddaa?", fontWeight = FontWeight.Bold)
      },
      text = {
        Column {
          Text(text = "Gaaffilee deebiste: $answeredCount")
          if (unansweredCount > 0) {
            Text(
              text = "Gaaffilee hin deebifamin: $unansweredCount",
              color = Color(0xFFDC2626),
              fontWeight = FontWeight.SemiBold
            )
          }
          Spacer(modifier = Modifier.height(8.dp))
          Text(
            text = "Yoo xumurtan bu'aa fi ibsa bal'aa ni argattu.",
            fontSize = 13.sp
          )
        }
      },
      confirmButton = {
        Button(
          onClick = {
            showConfirmSubmitDialog = false
            viewModel.submitExam()
          },
          modifier = Modifier.testTag("confirm_submit_btn")
        ) {
          Text("Eeyyee, Xumuri")
        }
      },
      dismissButton = {
        TextButton(onClick = { showConfirmSubmitDialog = false }) {
          Text("Itti Fufi")
        }
      }
    )
  }

  // Exit Confirmation Dialog
  if (showExitConfirmDialog) {
    AlertDialog(
      onDismissRequest = { showExitConfirmDialog = false },
      title = { Text("Qormaata Dhiistee Bahuu?") },
      text = { Text("Qormaata yoo dhiiste qabxiin kee hin galmaa'u.") },
      confirmButton = {
        Button(
          onClick = {
            showExitConfirmDialog = false
            onNavigateBack()
          },
          colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFDC2626))
        ) {
          Text("Bahi")
        }
      },
      dismissButton = {
        TextButton(onClick = { showExitConfirmDialog = false }) {
          Text("Qormaata Itti Fufi")
        }
      }
    )
  }
}

@Composable
fun LegendChip(label: String, color: Color) {
  Row(verticalAlignment = Alignment.CenterVertically) {
    Box(
      modifier = Modifier
        .size(10.dp)
        .clip(CircleShape)
        .background(color)
    )
    Spacer(modifier = Modifier.width(4.dp))
    Text(text = label, fontSize = 10.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
  }
}
