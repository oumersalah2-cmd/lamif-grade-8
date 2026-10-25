package com.example.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.data.local.entities.SyncQueueEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface SyncDao {
  @Query("SELECT * FROM sync_queue ORDER BY createdAt ASC")
  fun getQueue(): Flow<List<SyncQueueEntity>>

  @Query("SELECT * FROM sync_queue WHERE syncStatus = 'PENDING'")
  suspend fun getPendingSyncs(): List<SyncQueueEntity>

  @Query("SELECT count(*) FROM sync_queue WHERE syncStatus = 'PENDING'")
  fun getPendingCountFlow(): Flow<Int>

  @Insert(onConflict = OnConflictStrategy.REPLACE)
  suspend fun insertSyncItem(item: SyncQueueEntity)

  @Query("UPDATE sync_queue SET syncStatus = :status WHERE id = :id")
  suspend fun updateSyncStatus(id: String, status: String)

  @Query("UPDATE sync_queue SET syncStatus = 'SYNCED'")
  suspend fun markAllSynced()

  @Query("DELETE FROM sync_queue WHERE syncStatus = 'SYNCED'")
  suspend fun clearSynced()
}
