package com.example.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "bookmarks")
data class BookmarkEntity(
  @PrimaryKey
  val questionId: String,
  val savedAt: Long = System.currentTimeMillis()
)
