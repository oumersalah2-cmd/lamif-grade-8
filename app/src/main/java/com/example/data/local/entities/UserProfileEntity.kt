package com.example.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "user_profile")
data class UserProfileEntity(
  @PrimaryKey
  val id: String = "current_student",
  val fullName: String = "Barataa Kutaa 8ffaa",
  val phoneNumber: String = "+251911000000",
  val zoneName: String = "Shawaa Bahaa",
  val schoolName: String = "Mana Barumsaa Sad. 1ffaa",
  val targetScore: Int = 90,
  val isVerified: Boolean = false,
  val streakDays: Int = 3
)
