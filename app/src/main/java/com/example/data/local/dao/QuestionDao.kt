package com.example.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.data.local.entities.QuestionEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface QuestionDao {
  @Query("SELECT * FROM questions WHERE subjectId = :subjectId")
  fun getQuestionsBySubject(subjectId: String): Flow<List<QuestionEntity>>

  @Query("SELECT * FROM questions WHERE subjectId = :subjectId")
  suspend fun getQuestionsBySubjectDirect(subjectId: String): List<QuestionEntity>

  @Query("SELECT * FROM questions")
  fun getAllQuestions(): Flow<List<QuestionEntity>>

  @Query("SELECT * FROM questions WHERE id = :id LIMIT 1")
  suspend fun getQuestionById(id: String): QuestionEntity?

  @Query("SELECT * FROM questions WHERE id IN (:ids)")
  suspend fun getQuestionsByIds(ids: List<String>): List<QuestionEntity>

  @Query("SELECT count(*) FROM questions")
  suspend fun getQuestionsCount(): Int

  @Query("SELECT count(*) FROM questions WHERE subjectId = :subjectId")
  suspend fun getQuestionsCountBySubject(subjectId: String): Int

  @Insert(onConflict = OnConflictStrategy.REPLACE)
  suspend fun insertAll(questions: List<QuestionEntity>)
}
