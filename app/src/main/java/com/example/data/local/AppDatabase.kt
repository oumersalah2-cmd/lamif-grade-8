package com.example.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import com.example.data.local.dao.BookmarkDao
import com.example.data.local.dao.ExamDao
import com.example.data.local.dao.QuestionDao
import com.example.data.local.dao.StudySessionDao
import com.example.data.local.dao.SyncDao
import com.example.data.local.dao.UserDao
import com.example.data.local.entities.BookmarkEntity
import com.example.data.local.entities.ExamAttemptEntity
import com.example.data.local.entities.QuestionEntity
import com.example.data.local.entities.StudySessionEntity
import com.example.data.local.entities.SyncQueueEntity
import com.example.data.local.entities.UserProfileEntity
import com.example.data.preloaded.PreloadedQuestions
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.UUID

@Database(
  entities = [
    QuestionEntity::class,
    ExamAttemptEntity::class,
    BookmarkEntity::class,
    UserProfileEntity::class,
    SyncQueueEntity::class,
    StudySessionEntity::class
  ],
  version = 2,
  exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
  abstract fun questionDao(): QuestionDao
  abstract fun examDao(): ExamDao
  abstract fun bookmarkDao(): BookmarkDao
  abstract fun userDao(): UserDao
  abstract fun syncDao(): SyncDao
  abstract fun studySessionDao(): StudySessionDao

  companion object {
    @Volatile
    private var INSTANCE: AppDatabase? = null

    fun getDatabase(context: Context): AppDatabase {
      return INSTANCE ?: synchronized(this) {
        val instance = Room.databaseBuilder(
          context.applicationContext,
          AppDatabase::class.java,
          "lamif_kutaa8_db"
        )
        .addCallback(object : Callback() {
          override fun onCreate(db: SupportSQLiteDatabase) {
            super.onCreate(db)
            CoroutineScope(Dispatchers.IO).launch {
              val database = getDatabase(context)
              database.questionDao().insertAll(PreloadedQuestions.questions)
              database.userDao().saveUserProfile(
                UserProfileEntity(
                  id = "current_student",
                  fullName = "Barataa Kutaa 8ffaa",
                  phoneNumber = "+251911234567",
                  zoneName = "Shawaa Bahaa",
                  schoolName = "Mana Barumsaa Sad. 1ffaa",
                  targetScore = 90,
                  isVerified = false,
                  streakDays = 3
                )
              )
              seedInitialSessions(database)
            }
          }

          override fun onOpen(db: SupportSQLiteDatabase) {
            super.onOpen(db)
            CoroutineScope(Dispatchers.IO).launch {
              val database = getDatabase(context)
              if (database.questionDao().getQuestionsCount() == 0) {
                database.questionDao().insertAll(PreloadedQuestions.questions)
              }
              if (database.studySessionDao().getSessionsCount() == 0) {
                seedInitialSessions(database)
              }
            }
          }
        })
        .fallbackToDestructiveMigration()
        .build()
        INSTANCE = instance
        instance
      }
    }

    private suspend fun seedInitialSessions(database: AppDatabase) {
      val defaultSessions = listOf(
        StudySessionEntity(
          id = UUID.randomUUID().toString(),
          subjectId = "herrega",
          dayOfWeek = "WIIXATA",
          startTime = "04:00 PM",
          durationMinutes = 45,
          topicFocusOm = "Tiwooremii Paayitaagorasii shaakaluu",
          isCompleted = true
        ),
        StudySessionEntity(
          id = UUID.randomUUID().toString(),
          subjectId = "saayinsii_waliigalaa",
          dayOfWeek = "WIIXATA",
          startTime = "05:00 PM",
          durationMinutes = 45,
          topicFocusOm = "Lubbiyyoo fi Caasaalee Seelii",
          isCompleted = false
        ),
        StudySessionEntity(
          id = UUID.randomUUID().toString(),
          subjectId = "afaan_oromoo",
          dayOfWeek = "KIBXATA",
          startTime = "04:30 PM",
          durationMinutes = 40,
          topicFocusOm = "Dhamjecha Walabaa fi Hirkataa",
          isCompleted = false
        ),
        StudySessionEntity(
          id = UUID.randomUUID().toString(),
          subjectId = "herrega",
          dayOfWeek = "ROOBII",
          startTime = "04:00 PM",
          durationMinutes = 50,
          topicFocusOm = "Aljebraa fi Walqixxoo Sararaawaa",
          isCompleted = false
        ),
        StudySessionEntity(
          id = UUID.randomUUID().toString(),
          subjectId = "lammummaa",
          dayOfWeek = "KAMISA",
          startTime = "05:00 PM",
          durationMinutes = 35,
          topicFocusOm = "Heera Mootummaa fi Mirga Lammiilee",
          isCompleted = false
        ),
        StudySessionEntity(
          id = UUID.randomUUID().toString(),
          subjectId = "saayinsii_hawaasaa",
          dayOfWeek = "JIMAATA",
          startTime = "04:30 PM",
          durationMinutes = 45,
          topicFocusOm = "Sirna Gadaa Oromoo fi Seenaa",
          isCompleted = false
        ),
        StudySessionEntity(
          id = UUID.randomUUID().toString(),
          subjectId = "english",
          dayOfWeek = "SANBATA",
          startTime = "09:30 AM",
          durationMinutes = 45,
          topicFocusOm = "Grammar - Tenses & Passive Voice",
          isCompleted = false
        ),
      )
      database.studySessionDao().insertAll(defaultSessions)
    }
  }
}
