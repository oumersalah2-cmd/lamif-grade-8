package com.example.data.firestore

import android.content.Context
import com.example.R
import com.example.data.local.entities.ExamAttemptEntity
import com.example.data.local.entities.UserProfileEntity
import com.google.firebase.Firebase
import com.google.firebase.auth.auth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.snapshots
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.emitAll
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext

data class CloudUserProfile(
  val fullName: String = "",
  val phoneNumber: String = "",
  val schoolName: String = "",
  val zoneName: String = "",
  val targetScore: Double = 90.0,
  val streakDays: Double = 0.0
)

data class CloudExamAttempt(
  val subjectId: String = "",
  val examType: String = "",
  val totalQuestions: Double = 0.0,
  val correctAnswersCount: Double = 0.0,
  val scorePercentage: Double = 0.0,
  val timeTakenSeconds: Double = 0.0
)

class FirestoreSyncRepository(
  private val db: FirebaseFirestore
) {
  constructor(context: Context) : this(
    FirebaseFirestore.getInstance(
      context.applicationContext.getString(R.string.firestore_database_id)
    )
  )

  private val auth = Firebase.auth

  private fun requireUserId(): String {
    return auth.currentUser?.uid
      ?: throw IllegalStateException("User must be signed in with Google before accessing Firestore.")
  }

  suspend fun syncUserProfileToCloud(profile: UserProfileEntity) = withContext(Dispatchers.IO) {
    val uid = requireUserId()
    val docRef = db.collection("users").document(uid)
    val data = mapOf(
      "fullName" to profile.fullName.ifBlank { "Barataa Kutaa 8ffaa" },
      "phoneNumber" to profile.phoneNumber,
      "schoolName" to profile.schoolName.ifBlank { "Mana Barumsaa Sad. 1ffaa" },
      "zoneName" to profile.zoneName.ifBlank { "Shawaa Bahaa" },
      "targetScore" to profile.targetScore.toDouble(),
      "streakDays" to profile.streakDays.toDouble()
    )
    try {
      docRef.set(data).await()
    } catch (e: Exception) {
      handleFirestoreError(e, OperationType.WRITE, docRef.path)
      throw e
    }
  }

  suspend fun syncExamAttemptToCloud(attempt: ExamAttemptEntity) = withContext(Dispatchers.IO) {
    val uid = requireUserId()
    val docRef = db.collection("users").document(uid)
      .collection("exam_attempts").document(attempt.id)
    val data = mapOf(
      "subjectId" to attempt.subjectId,
      "examType" to attempt.examType,
      "totalQuestions" to attempt.totalQuestions.toDouble(),
      "correctAnswersCount" to attempt.correctAnswersCount.toDouble(),
      "scorePercentage" to attempt.scorePercentage.toDouble(),
      "timeTakenSeconds" to attempt.timeTakenSeconds.toDouble()
    )
    try {
      docRef.set(data).await()
    } catch (e: Exception) {
      handleFirestoreError(e, OperationType.CREATE, docRef.path)
      throw e
    }
  }

  fun observeCloudAttempts(): Flow<List<CloudExamAttempt>> = flow {
    val uid = requireUserId()
    val path = "users/$uid/exam_attempts"
    emitAll(
      db.collection("users").document(uid)
        .collection("exam_attempts")
        .snapshots()
        .map { snapshot -> snapshot.toObjects(CloudExamAttempt::class.java) }
        .catch { error ->
          if (error is Exception) handleFirestoreError(error, OperationType.LIST, path)
          throw error
        }
    )
  }
}
