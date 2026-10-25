package com.example.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "exam_attempts")
data class ExamAttemptEntity(
  @PrimaryKey
  val id: String,
  val subjectId: String,
  val examType: String, // "MOCK_MINISTRY" or "PRACTICE"
  val totalQuestions: Int,
  val correctAnswersCount: Int,
  val scorePercentage: Int,
  val timeTakenSeconds: Long,
  val timestamp: Long = System.currentTimeMillis(),
  val userAnswersMapJson: String, // "questionId:selectedOptionIndex,..."
  val isSynced: Boolean = false
)
