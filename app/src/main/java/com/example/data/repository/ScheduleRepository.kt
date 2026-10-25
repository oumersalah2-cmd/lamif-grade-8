package com.example.data.repository

import com.example.data.local.AppDatabase
import com.example.data.local.entities.StudySessionEntity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext

class ScheduleRepository(private val db: AppDatabase) {

  fun getSessionsForDay(dayOfWeek: String): Flow<List<StudySessionEntity>> {
    return db.studySessionDao().getSessionsForDay(dayOfWeek)
  }

  fun getAllSessions(): Flow<List<StudySessionEntity>> {
    return db.studySessionDao().getAllSessions()
  }

  suspend fun addSession(session: StudySessionEntity) = withContext(Dispatchers.IO) {
    db.studySessionDao().insertSession(session)
  }

  suspend fun toggleSessionCompleted(id: String, isCompleted: Boolean) = withContext(Dispatchers.IO) {
    db.studySessionDao().setCompleted(id, isCompleted)
  }

  suspend fun deleteSession(id: String) = withContext(Dispatchers.IO) {
    db.studySessionDao().deleteSession(id)
  }
}
