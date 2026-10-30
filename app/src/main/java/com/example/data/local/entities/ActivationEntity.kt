package com.example.data.local.entities

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Stores the offline activation status, Device ID, and cryptographic details.
 */
@Entity(tableName = "activation")
data class ActivationEntity(
  @PrimaryKey
  val id: String = "primary_activation",
  val deviceId: String,
  val isActivated: Boolean = false,
  val plan: String = "NONE", // "NONE", "LIFETIME", "EXPIRING", "PROMO"
  val expiryTimestamp: Long? = null, // Unix timestamp in seconds (null = never expires)
  val activationToken: String = "",
  val activatedAt: Long = 0L,
  val lastKnownTimestamp: Long = 0L // To detect rollback/clock tampering
)
