package com.example.data.repository

import com.example.data.local.AppDatabase
import com.example.data.local.entities.BookmarkEntity
import com.example.data.local.entities.ExamAttemptEntity
import com.example.data.local.entities.QuestionEntity
import com.example.data.local.entities.SyncQueueEntity
import com.example.data.local.entities.UserProfileEntity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.withContext
import java.util.UUID

class ExamRepository(private val db: AppDatabase) {

  fun getQuestionsForSubject(subjectId: String): Flow<List<QuestionEntity>> =
    db.questionDao().getQuestionsBySubject(subjectId)

  suspend fun getQuestionsForSubjectDirect(subjectId: String): List<QuestionEntity> =
    withContext(Dispatchers.IO) {
      db.questionDao().getQuestionsBySubjectDirect(subjectId)
    }

  fun getAllQuestions(): Flow<List<QuestionEntity>> =
    db.questionDao().getAllQuestions()

  suspend fun getQuestionById(id: String): QuestionEntity? =
    withContext(Dispatchers.IO) {
      db.questionDao().getQuestionById(id)
    }

  suspend fun getQuestionsByIds(ids: List<String>): List<QuestionEntity> =
    withContext(Dispatchers.IO) {
      db.questionDao().getQuestionsByIds(ids)
    }

  fun getAllAttempts(): Flow<List<ExamAttemptEntity>> =
    db.examDao().getAllAttempts()

  fun getAttemptsBySubject(subjectId: String): Flow<List<ExamAttemptEntity>> =
    db.examDao().getAttemptsBySubject(subjectId)

  suspend fun saveExamAttempt(attempt: ExamAttemptEntity): ExamAttemptEntity =
    withContext(Dispatchers.IO) {
      // 1. Save attempt locally in Room
      db.examDao().insertAttempt(attempt)

      // 2. Queue in SyncQueue for offline-first resilience
      val syncItem = SyncQueueEntity(
        id = UUID.randomUUID().toString(),
        itemType = "EXAM_RESULT",
        payloadJson = "{\"attemptId\":\"${attempt.id}\",\"subjectId\":\"${attempt.subjectId}\",\"score\":${attempt.scorePercentage},\"correct\":${attempt.correctAnswersCount},\"total\":${attempt.totalQuestions}}",
        createdAt = System.currentTimeMillis(),
        syncStatus = "PENDING"
      )
      db.syncDao().insertSyncItem(syncItem)

      attempt
    }

  fun isBookmarked(questionId: String): Flow<Boolean> =
    db.bookmarkDao().isBookmarked(questionId)

  fun getAllBookmarks(): Flow<List<BookmarkEntity>> =
    db.bookmarkDao().getAllBookmarks()

  suspend fun toggleBookmark(questionId: String): Boolean =
    withContext(Dispatchers.IO) {
      val exists = db.bookmarkDao().isBookmarkedDirect(questionId)
      if (exists) {
        db.bookmarkDao().removeBookmark(questionId)
        false
      } else {
        db.bookmarkDao().insertBookmark(BookmarkEntity(questionId = questionId))
        true
      }
    }

  fun getUserProfile(): Flow<UserProfileEntity?> =
    db.userDao().getUserProfile()

  suspend fun saveUserProfile(profile: UserProfileEntity) =
    withContext(Dispatchers.IO) {
      db.userDao().saveUserProfile(profile)
    }

  fun getPendingSyncCount(): Flow<Int> =
    db.syncDao().getPendingCountFlow()

  suspend fun syncPendingData(): Int =
    withContext(Dispatchers.IO) {
      val pendingList = db.syncDao().getPendingSyncs()
      val count = pendingList.size
      if (count > 0) {
        // Mark sync queue items synced and update exam attempts
        db.syncDao().markAllSynced()
        db.examDao().markAllAttemptsSynced()
      }
      count
    }

  suspend fun getMistakeQuestionIds(): List<String> =
    withContext(Dispatchers.IO) {
      val attempts = db.examDao().getAllAttempts().firstOrNull() ?: emptyList()
      val mistakeIds = mutableSetOf<String>()
      for (attempt in attempts) {
        // userAnswersMapJson is encoded as "qid:selectedIdx:isCorrect,..."
        val entries = attempt.userAnswersMapJson.split(";")
        for (entry in entries) {
          val parts = entry.split(":")
          if (parts.size >= 3 && parts[2] == "0") {
            mistakeIds.add(parts[0])
          }
        }
      }
      mistakeIds.toList()
    }
}
