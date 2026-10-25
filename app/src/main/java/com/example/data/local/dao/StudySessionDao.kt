package com.example.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.example.data.local.entities.StudySessionEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface StudySessionDao {
  @Query("SELECT * FROM study_sessions WHERE dayOfWeek = :dayOfWeek ORDER BY startTime ASC")
  fun getSessionsForDay(dayOfWeek: String): Flow<List<StudySessionEntity>>

  @Query("SELECT * FROM study_sessions WHERE dayOfWeek = :dayOfWeek ORDER BY startTime ASC")
  suspend fun getSessionsListForDay(dayOfWeek: String): List<StudySessionEntity>

  @Query("SELECT * FROM study_sessions ORDER BY createdAt DESC")
  fun getAllSessions(): Flow<List<StudySessionEntity>>

  @Query("SELECT count(*) FROM study_sessions")
  suspend fun getSessionsCount(): Int

  @Insert(onConflict = OnConflictStrategy.REPLACE)
  suspend fun insertSession(session: StudySessionEntity)

  @Insert(onConflict = OnConflictStrategy.REPLACE)
  suspend fun insertAll(sessions: List<StudySessionEntity>)

  @Update
  suspend fun updateSession(session: StudySessionEntity)

  @Query("UPDATE study_sessions SET isCompleted = :isCompleted WHERE id = :id")
  suspend fun setCompleted(id: String, isCompleted: Boolean)

  @Query("DELETE FROM study_sessions WHERE id = :id")
  suspend fun deleteSession(id: String)
}
