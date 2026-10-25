package com.example.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "study_sessions")
data class StudySessionEntity(
  @PrimaryKey
  val id: String,
  val subjectId: String,
  val dayOfWeek: String, // "WIIXATA", "KIBXATA", "ROOBII", "KAMISA", "JIMAATA", "SANBATA", "DILBATA"
  val startTime: String, // e.g. "04:30 PM"
  val durationMinutes: Int, // e.g. 45
  val topicFocusOm: String, // e.g. "Tiwooremii Paayitaagorasii shaakaluu"
  val isCompleted: Boolean = false,
  val createdAt: Long = System.currentTimeMillis()
)
