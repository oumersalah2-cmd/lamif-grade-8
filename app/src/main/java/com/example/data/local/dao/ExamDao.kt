package com.example.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.data.local.entities.ExamAttemptEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface ExamDao {
  @Query("SELECT * FROM exam_attempts ORDER BY timestamp DESC")
  fun getAllAttempts(): Flow<List<ExamAttemptEntity>>

  @Query("SELECT * FROM exam_attempts WHERE subjectId = :subjectId ORDER BY timestamp DESC")
  fun getAttemptsBySubject(subjectId: String): Flow<List<ExamAttemptEntity>>

  @Query("SELECT * FROM exam_attempts WHERE id = :id LIMIT 1")
  suspend fun getAttemptById(id: String): ExamAttemptEntity?

  @Query("SELECT * FROM exam_attempts WHERE isSynced = 0")
  suspend fun getUnsyncedAttempts(): List<ExamAttemptEntity>

  @Query("UPDATE exam_attempts SET isSynced = 1 WHERE id = :id")
  suspend fun markAttemptSynced(id: String)

  @Query("UPDATE exam_attempts SET isSynced = 1")
  suspend fun markAllAttemptsSynced()

  @Insert(onConflict = OnConflictStrategy.REPLACE)
  suspend fun insertAttempt(attempt: ExamAttemptEntity)
}
