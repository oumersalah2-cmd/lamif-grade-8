package com.example.features.results

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
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.BookmarkBorder
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.CloudDone
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.local.entities.ExamAttemptEntity
import com.example.data.local.entities.QuestionEntity
import com.example.features.exams.ExamViewModel
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExamResultScreen(
  viewModel: ExamViewModel,
  onRetakeExam: () -> Unit,
  onGoHome: () -> Unit,
  modifier: Modifier = Modifier
) {
  val state by viewModel.uiState.collectAsState()
  val attempt = state.completedAttempt ?: return

  var selectedFilter by remember { mutableStateOf("ALL") } // "ALL", "MISTAKES", "CORRECT"

  val questions = state.questions
  val answersMap = remember(attempt.userAnswersMapJson) {
    // parse "qid:selectedOption:isCorrect"
    val map = mutableMapOf<String, Pair<Int, Boolean>>()
    val entries = attempt.userAnswersMapJson.split(";")
    for (entry in entries) {
      val parts = entry.split(":")
      if (parts.size >= 3) {
        val qid = parts[0]
        val sel = parts[1].toIntOrNull() ?: -1
        val corr = parts[2] == "1"
        map[qid] = Pair(sel, corr)
      }
    }
    map
  }

  val filteredQuestions = questions.filter { q ->
    val pair = answersMap[q.id]
    val isCorrect = pair?.second == true
    when (selectedFilter) {
      "MISTAKES" -> !isCorrect
      "CORRECT" -> isCorrect
      else -> true
    }
  }

  Scaffold(
    topBar = {
      TopAppBar(
        title = {
          Text(
            text = "Bu'aa Qormaataa (Results)",
            fontWeight = FontWeight.Bold,
            fontSize = 18.sp
          )
        },
        actions = {
          IconButton(onClick = onGoHome, modifier = Modifier.testTag("result_home_btn")) {
            Icon(imageVector = Icons.Default.Home, contentDescription = "Mana")
          }
        },
        colors = TopAppBarDefaults.topAppBarColors(
          containerColor = MaterialTheme.colorScheme.surface
        )
      )
    },
    bottomBar = {
      Surface(
        tonalElevation = 6.dp,
        shadowElevation = 6.dp,
        color = MaterialTheme.colorScheme.surface
      ) {
        Row(
          modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
          horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
          OutlinedButton(
            onClick = onRetakeExam,
            modifier = Modifier
              .weight(1f)
              .testTag("retake_exam_btn"),
            shape = RoundedCornerShape(12.dp)
          ) {
            Icon(imageVector = Icons.Default.Refresh, contentDescription = null, modifier = Modifier.size(16.dp))
            Spacer(modifier = Modifier.width(6.dp))
            Text("Irra Deebi'i")
          }

          Button(
            onClick = onGoHome,
            modifier = Modifier
              .weight(1f)
              .testTag("back_to_home_btn"),
            shape = RoundedCornerShape(12.dp)
          ) {
            Icon(imageVector = Icons.Default.Home, contentDescription = null, modifier = Modifier.size(16.dp))
            Spacer(modifier = Modifier.width(6.dp))
            Text("Gara Manaa")
          }
        }
      }
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
      // 1. Result Score Card
      item {
        Card(
          shape = RoundedCornerShape(20.dp),
          colors = CardDefaults.cardColors(containerColor = Color.Transparent),
          modifier = Modifier.fillMaxWidth()
        ) {
          val score = attempt.scorePercentage
          val gradientColors = when {
            score >= 75 -> listOf(Color(0xFF16A34A), Color(0xFF15803D))
            score >= 50 -> listOf(Color(0xFFD97706), Color(0xFFB45309))
            else -> listOf(Color(0xFFDC2626), Color(0xFF991B1B))
          }

          Box(
            modifier = Modifier
              .background(Brush.verticalGradient(gradientColors))
              .padding(24.dp)
              .fillMaxWidth(),
            contentAlignment = Alignment.Center
          ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
              // Circle Score Badge
              Box(
                modifier = Modifier
                  .size(100.dp)
                  .clip(CircleShape)
                  .background(Color.White),
                contentAlignment = Alignment.Center
              ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                  Text(
                    text = "$score%",
                    fontSize = 26.sp,
                    fontWeight = FontWeight.ExtraBold,
                    color = gradientColors[0]
                  )
                  Text(
                    text = "${attempt.correctAnswersCount}/${attempt.totalQuestions}",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium,
                    color = Color.DarkGray
                  )
                }
              }

              Spacer(modifier = Modifier.height(14.dp))

              val remarkOm = when {
                score >= 85 -> "Baay'ee Gaarii dha! (Qabxii Ol'aanaa) 🌟"
                score >= 70 -> "Gaarii dha! Qophii kee jabeessi 👍"
                score >= 50 -> "Darbiinsa Qormaata Naannoo Oromiyaa"
                else -> "Dabalata Shaakaluu Barbaachisa 📚"
              }

              Text(
                text = remarkOm,
                color = Color.White,
                fontSize = 17.sp,
                fontWeight = FontWeight.Bold
              )

              Spacer(modifier = Modifier.height(4.dp))
              Text(
                text = state.subject.afaanOromoName,
                color = Color.White.copy(alpha = 0.85f),
                fontSize = 13.sp
              )

              Spacer(modifier = Modifier.height(14.dp))

              // Storage & Sync Badge
              Surface(
                shape = RoundedCornerShape(12.dp),
                color = Color.White.copy(alpha = 0.2f)
              ) {
                Row(
                  modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                  verticalAlignment = Alignment.CenterVertically
                ) {
                  Icon(
                    imageVector = Icons.Default.CloudDone,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(14.dp)
                  )
                  Spacer(modifier = Modifier.width(4.dp))
                  Text(
                    text = "Qabxiin kee moobaayila irratti kuufameera (Offline-first)",
                    fontSize = 11.sp,
                    color = Color.White,
                    fontWeight = FontWeight.Medium
                  )
                }
              }
            }
          }
        }
      }

      // 2. Metrics Breakdown Row
      item {
        val minutes = attempt.timeTakenSeconds / 60
        val seconds = attempt.timeTakenSeconds % 60
        val timeFormatted = String.format(Locale.getDefault(), "%02d:%02d", minutes, seconds)

        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
          MetricBox(
            label = "Sirrii",
            value = "${attempt.correctAnswersCount}",
            color = Color(0xFF16A34A),
            modifier = Modifier.weight(1f)
          )
          MetricBox(
            label = "Dogoggora",
            value = "${attempt.totalQuestions - attempt.correctAnswersCount}",
            color = Color(0xFFDC2626),
            modifier = Modifier.weight(1f)
          )
          MetricBox(
            label = "Yeroo",
            value = timeFormatted,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.weight(1f)
          )
        }
      }

      // 3. Review Questions Filter Chips
      item {
        Text(
          text = "Koreeffama fi Ibsa Gaaffilee (Review)",
          fontWeight = FontWeight.Bold,
          fontSize = 16.sp
        )

        Spacer(modifier = Modifier.height(6.dp))

        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
          FilterChip(
            selected = selectedFilter == "ALL",
            onClick = { selectedFilter = "ALL" },
            label = { Text("Hunda (${questions.size})", fontSize = 12.sp) }
          )
          FilterChip(
            selected = selectedFilter == "MISTAKES",
            onClick = { selectedFilter = "MISTAKES" },
            label = { Text("Dogoggora (${attempt.totalQuestions - attempt.correctAnswersCount})", fontSize = 12.sp) }
          )
          FilterChip(
            selected = selectedFilter == "CORRECT",
            onClick = { selectedFilter = "CORRECT" },
            label = { Text("Sirrii (${attempt.correctAnswersCount})", fontSize = 12.sp) }
          )
        }
      }

      // 4. Questions List
      itemsIndexed(filteredQuestions) { _, question ->
        val userPair = answersMap[question.id]
        val selectedOptionIdx = userPair?.first ?: -1
        val isCorrect = userPair?.second == true

        ReviewQuestionCard(
          question = question,
          selectedOptionIdx = selectedOptionIdx,
          isCorrect = isCorrect,
          isBookmarked = state.bookmarkedQuestions.contains(question.id),
          onToggleBookmark = { viewModel.toggleBookmarkCurrentQuestion() }
        )
      }
    }
  }
}

@Composable
fun MetricBox(
  label: String,
  value: String,
  color: Color,
  modifier: Modifier = Modifier
) {
  Surface(
    shape = RoundedCornerShape(12.dp),
    color = color.copy(alpha = 0.08f),
    modifier = modifier
  ) {
    Column(
      modifier = Modifier.padding(vertical = 12.dp),
      horizontalAlignment = Alignment.CenterHorizontally
    ) {
      Text(
        text = value,
        fontWeight = FontWeight.Bold,
        fontSize = 16.sp,
        color = color
      )
      Text(
        text = label,
        fontSize = 11.sp,
        color = MaterialTheme.colorScheme.onSurfaceVariant
      )
    }
  }
}

@Composable
fun ReviewQuestionCard(
  question: QuestionEntity,
  selectedOptionIdx: Int,
  isCorrect: Boolean,
  isBookmarked: Boolean,
  onToggleBookmark: () -> Unit
) {
  Card(
    shape = RoundedCornerShape(16.dp),
    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
    elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
    modifier = Modifier.fillMaxWidth()
  ) {
    Column(modifier = Modifier.padding(16.dp)) {
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Surface(
          shape = RoundedCornerShape(6.dp),
          color = if (isCorrect) Color(0xFFD4EDDA) else Color(0xFFFEE2E2)
        ) {
          Row(
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
            verticalAlignment = Alignment.CenterVertically
          ) {
            Icon(
              imageVector = if (isCorrect) Icons.Default.Check else Icons.Default.Close,
              contentDescription = null,
              tint = if (isCorrect) Color(0xFF155D27) else Color(0xFF991B1B),
              modifier = Modifier.size(14.dp)
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text(
              text = if (isCorrect) "Sirrii" else "Dogoggora",
              fontSize = 11.sp,
              fontWeight = FontWeight.Bold,
              color = if (isCorrect) Color(0xFF155D27) else Color(0xFF991B1B)
            )
          }
        }

        IconButton(onClick = onToggleBookmark, modifier = Modifier.size(32.dp)) {
          Icon(
            imageVector = if (isBookmarked) Icons.Default.Bookmark else Icons.Default.BookmarkBorder,
            contentDescription = "Qabadhu",
            tint = if (isBookmarked) Color(0xFFD97706) else MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.size(20.dp)
          )
        }
      }

      Spacer(modifier = Modifier.height(8.dp))

      Text(
        text = question.questionTextOm,
        fontSize = 15.sp,
        fontWeight = FontWeight.Medium,
        color = MaterialTheme.colorScheme.onSurface
      )

      Spacer(modifier = Modifier.height(10.dp))

      val options = listOf(question.optionA, question.optionB, question.optionC, question.optionD)
      val letters = listOf("A", "B", "C", "D")

      options.forEachIndexed { idx, opt ->
        val isChosen = selectedOptionIdx == idx
        val isRightAnswer = idx == question.correctOptionIndex

        val bg = when {
          isRightAnswer -> Color(0xFF16A34A).copy(alpha = 0.1f)
          isChosen && !isRightAnswer -> Color(0xFFDC2626).copy(alpha = 0.1f)
          else -> Color.Transparent
        }

        Surface(
          shape = RoundedCornerShape(8.dp),
          color = bg,
          modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 2.dp)
        ) {
          Row(
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically
          ) {
            Text(
              text = "${letters[idx]}. ",
              fontWeight = FontWeight.Bold,
              fontSize = 13.sp,
              color = if (isRightAnswer) Color(0xFF16A34A) else if (isChosen) Color(0xFFDC2626) else MaterialTheme.colorScheme.onSurface
            )
            Text(
              text = opt,
              fontSize = 13.sp,
              color = MaterialTheme.colorScheme.onSurface,
              modifier = Modifier.weight(1f)
            )
            if (isRightAnswer) {
              Text("(Deebii Sirrii)", fontSize = 11.sp, color = Color(0xFF16A34A), fontWeight = FontWeight.Bold)
            } else if (isChosen) {
              Text("(Filannoo Kee)", fontSize = 11.sp, color = Color(0xFFDC2626), fontWeight = FontWeight.Bold)
            }
          }
        }
      }

      Spacer(modifier = Modifier.height(10.dp))

      // Explanation
      Surface(
        shape = RoundedCornerShape(10.dp),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f),
        modifier = Modifier.fillMaxWidth()
      ) {
        Column(modifier = Modifier.padding(10.dp)) {
          Text(
            text = "Ibsa Deebii (Rationale):",
            fontSize = 12.sp,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.primary
          )
          Spacer(modifier = Modifier.height(2.dp))
          Text(
            text = question.explanationOm,
            fontSize = 12.sp,
            lineHeight = 17.sp,
            color = MaterialTheme.colorScheme.onSurface
          )
        }
      }
    }
  }
}
