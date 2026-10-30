package com.example.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.data.local.entities.ActivationEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface ActivationDao {
  @Query("SELECT * FROM activation WHERE id = 'primary_activation' LIMIT 1")
  fun getActivationFlow(): Flow<ActivationEntity?>

  @Query("SELECT * FROM activation WHERE id = 'primary_activation' LIMIT 1")
  suspend fun getActivation(): ActivationEntity?

  @Insert(onConflict = OnConflictStrategy.REPLACE)
  suspend fun saveActivation(entity: ActivationEntity)

  @Query("UPDATE activation SET lastKnownTimestamp = :timestamp WHERE id = 'primary_activation'")
  suspend fun updateLastTimestamp(timestamp: Long)

  @Query("DELETE FROM activation")
  suspend fun clearActivation()
}
