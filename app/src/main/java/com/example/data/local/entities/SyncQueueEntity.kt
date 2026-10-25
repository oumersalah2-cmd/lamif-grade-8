package com.example.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "sync_queue")
data class SyncQueueEntity(
  @PrimaryKey
  val id: String,
  val itemType: String, // "EXAM_RESULT", "PROFILE"
  val payloadJson: String,
  val createdAt: Long = System.currentTimeMillis(),
  val syncStatus: String = "PENDING" // "PENDING", "SYNCED", "FAILED"
)
