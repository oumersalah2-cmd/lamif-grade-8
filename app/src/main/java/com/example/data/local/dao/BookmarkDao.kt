package com.example.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.data.local.entities.BookmarkEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface BookmarkDao {
  @Query("SELECT * FROM bookmarks ORDER BY savedAt DESC")
  fun getAllBookmarks(): Flow<List<BookmarkEntity>>

  @Query("SELECT EXISTS(SELECT 1 FROM bookmarks WHERE questionId = :questionId)")
  fun isBookmarked(questionId: String): Flow<Boolean>

  @Query("SELECT EXISTS(SELECT 1 FROM bookmarks WHERE questionId = :questionId)")
  suspend fun isBookmarkedDirect(questionId: String): Boolean

  @Insert(onConflict = OnConflictStrategy.REPLACE)
  suspend fun insertBookmark(bookmark: BookmarkEntity)

  @Query("DELETE FROM bookmarks WHERE questionId = :questionId")
  suspend fun removeBookmark(questionId: String)
}
