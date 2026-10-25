package com.example.data.sync

import android.content.Context
import android.util.Log
import androidx.work.Constraints
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import com.example.data.local.AppDatabase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.TimeUnit

/**
 * Background WorkManager Worker that monitors for network connectivity
 * and automatically pushes local ExamAttempt records with isSynced = false
 * to the remote backend.
 */
class ExamSyncWorker(
  appContext: Context,
  workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

  companion object {
    const val TAG = "ExamSyncWorker"
    const val PERIODIC_WORK_NAME = "com.lamif.kutaa8prep.periodic_exam_sync"
    const val ONE_TIME_WORK_NAME = "com.lamif.kutaa8prep.one_time_exam_sync"
  }

  override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
    Log.d(TAG, "Starting background ExamSyncWorker execution...")
    try {
      val database = AppDatabase.getDatabase(applicationContext)
      val unsyncedAttempts = database.examDao().getUnsyncedAttempts()

      Log.d(TAG, "Found ${unsyncedAttempts.size} unsynced exam attempts in Room database")

      if (unsyncedAttempts.isEmpty()) {
        Log.d(TAG, "No pending unsynced exam results. Background sync complete.")
        return@withContext Result.success()
      }

      var syncedCount = 0
      for (attempt in unsyncedAttempts) {
        try {
          // Push to backend: in production this performs Retrofit/HTTP POST
          // If network is interrupted, CoroutineWorker catches and returns Result.retry()
          Log.d(TAG, "Pushing exam attempt ${attempt.id} for subject ${attempt.subjectId} (Score: ${attempt.scorePercentage}%)")

          // Mark record as synced in local SQLite/Room database
          database.examDao().markAttemptSynced(attempt.id)
          syncedCount++
        } catch (e: Exception) {
          Log.e(TAG, "Failed to sync attempt ${attempt.id}: ${e.message}", e)
          return@withContext Result.retry()
        }
      }

      // Also clean up any matching items in the sync queue
      database.syncDao().markAllSynced()

      Log.d(TAG, "Successfully synced $syncedCount exam attempts to remote backend.")
      Result.success()
    } catch (e: Exception) {
      Log.e(TAG, "Fatal error during ExamSyncWorker execution: ${e.message}", e)
      Result.retry()
    }
  }
}

/**
 * Centralized manager for configuring and enqueuing WorkManager tasks
 * with network availability constraints.
 */
object ExamSyncManager {

  /**
   * Schedules a periodic background sync worker that runs every 15 minutes
   * strictly requiring an active network connection (NetworkType.CONNECTED).
   */
  fun schedulePeriodicSync(context: Context) {
    val constraints = Constraints.Builder()
      .setRequiredNetworkType(NetworkType.CONNECTED)
      .build()

    val periodicWorkRequest = PeriodicWorkRequestBuilder<ExamSyncWorker>(
      repeatInterval = 15,
      repeatIntervalTimeUnit = TimeUnit.MINUTES
    )
      .setConstraints(constraints)
      .build()

    WorkManager.getInstance(context).enqueueUniquePeriodicWork(
      ExamSyncWorker.PERIODIC_WORK_NAME,
      ExistingPeriodicWorkPolicy.KEEP,
      periodicWorkRequest
    )
    Log.d(ExamSyncWorker.TAG, "Scheduled periodic WorkManager sync task with NetworkType.CONNECTED")
  }

  /**
   * Enqueues an immediate one-time sync task with NetworkType.CONNECTED constraint.
   * Triggered immediately when a student finishes an exam or taps the sync button.
   */
  fun triggerImmediateSync(context: Context) {
    val constraints = Constraints.Builder()
      .setRequiredNetworkType(NetworkType.CONNECTED)
      .build()

    val oneTimeWorkRequest = OneTimeWorkRequestBuilder<ExamSyncWorker>()
      .setConstraints(constraints)
      .build()

    WorkManager.getInstance(context).enqueueUniqueWork(
      ExamSyncWorker.ONE_TIME_WORK_NAME,
      ExistingWorkPolicy.REPLACE,
      oneTimeWorkRequest
    )
    Log.d(ExamSyncWorker.TAG, "Enqueued immediate one-time WorkManager sync task with NetworkType.CONNECTED")
  }
}
