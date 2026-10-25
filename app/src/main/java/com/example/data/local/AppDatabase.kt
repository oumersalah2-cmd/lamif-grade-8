package com.example.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import com.example.data.local.dao.BookmarkDao
import com.example.data.local.dao.ExamDao
import com.example.data.local.dao.QuestionDao
import com.example.data.local.dao.SyncDao
import com.example.data.local.dao.UserDao
import com.example.data.local.entities.BookmarkEntity
import com.example.data.local.entities.ExamAttemptEntity
import com.example.data.local.entities.QuestionEntity
import com.example.data.local.entities.SyncQueueEntity
import com.example.data.local.entities.UserProfileEntity
import com.example.data.preloaded.PreloadedQuestions
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Database(
  entities = [
    QuestionEntity::class,
    ExamAttemptEntity::class,
    BookmarkEntity::class,
    UserProfileEntity::class,
    SyncQueueEntity::class
  ],
  version = 1,
  exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
  abstract fun questionDao(): QuestionDao
  abstract fun examDao(): ExamDao
  abstract fun bookmarkDao(): BookmarkDao
  abstract fun userDao(): UserDao
  abstract fun syncDao(): SyncDao

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
            }
          }

          override fun onOpen(db: SupportSQLiteDatabase) {
            super.onOpen(db)
            // Ensure preloaded questions exist
            CoroutineScope(Dispatchers.IO).launch {
              val database = getDatabase(context)
              if (database.questionDao().getQuestionsCount() == 0) {
                database.questionDao().insertAll(PreloadedQuestions.questions)
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
  }
}
