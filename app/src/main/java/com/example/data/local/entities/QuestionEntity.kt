package com.example.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "questions")
data class QuestionEntity(
  @PrimaryKey
  val id: String,
  val subjectId: String,
  val topicOm: String,
  val questionTextOm: String,
  val questionTextEn: String = "",
  val optionA: String,
  val optionB: String,
  val optionC: String,
  val optionD: String,
  val correctOptionIndex: Int, // 0 for A, 1 for B, 2 for C, 3 for D
  val explanationOm: String,
  val explanationEn: String = "",
  val examYear: String = "2016 E.C.",
  val difficulty: String = "Medium"
)
