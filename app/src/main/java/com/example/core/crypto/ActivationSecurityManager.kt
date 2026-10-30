package com.example.core.crypto

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import com.example.data.local.AppDatabase
import com.example.data.local.entities.ActivationEntity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.security.KeyStore
import java.security.MessageDigest
import java.util.UUID
import javax.crypto.KeyGenerator
import javax.crypto.Mac
import javax.crypto.SecretKey
import javax.crypto.spec.SecretKeySpec

sealed class ActivationResult {
  data class Success(val plan: String, val expiryTimestamp: Long?) : ActivationResult()
  data class Error(val messageOm: String, val technicalReason: String) : ActivationResult()
}

/**
 * Manages Device ID generation, Ed25519 offline verification,
 * Keystore tamper protection, and clock manipulation defense.
 */
class ActivationSecurityManager(
  private val context: Context,
  private val database: AppDatabase = AppDatabase.getDatabase(context)
) {

  private val prefs = context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

  /**
   * Returns a persistent Device ID derived from a random UUID.
   * Generated once on first install and stored in secure prefs and Room.
   */
  fun getOrCreateDeviceId(): String {
    val existing = prefs.getString(KEY_DEVICE_ID, null)
    if (!existing.isNullOrBlank()) {
      return existing
    }

    val raw = UUID.randomUUID().toString().replace("-", "").take(12).uppercase()
    val formatted = "LMF-${raw.substring(0, 4)}-${raw.substring(4, 8)}-${raw.substring(8, 12)}"
    prefs.edit().putString(KEY_DEVICE_ID, formatted).apply()
    return formatted
  }

  /**
   * Flow that emits whether the app is fully activated.
   */
  val isActivatedFlow: Flow<Boolean> = database.activationDao().getActivationFlow().map { entity ->
    isActivationValid(entity)
  }

  suspend fun isCurrentlyActivated(): Boolean = withContext(Dispatchers.IO) {
    val entity = database.activationDao().getActivation()
    isActivationValid(entity)
  }

  /**
   * Validates database activation record against Keystore HMAC, Ed25519, and clock sanity.
   */
  private fun isActivationValid(entity: ActivationEntity?): Boolean {
    if (entity == null || !entity.isActivated) return false

    val currentNow = System.currentTimeMillis() / 1000L

    // 1. Clock Rollback Protection (Student set phone clock backwards to cheat expiry)
    if (entity.expiryTimestamp != null) {
      val savedLastTime = prefs.getLong(KEY_LAST_TIMESTAMP, entity.lastKnownTimestamp)
      if (currentNow < savedLastTime - 300) { // 5-minute skew tolerance
        return false // Clock tampering detected
      }
      if (currentNow > entity.expiryTimestamp) {
        return false // License expired
      }
    }

    // 2. Hardware Keystore / HMAC Tamper Verification
    val savedHmac = prefs.getString(KEY_ACTIVATION_HMAC, null)
    val computedHmac = computeStateHmac(entity.deviceId, entity.plan, entity.expiryTimestamp, entity.activationToken)
    if (savedHmac == null || savedHmac != computedHmac) {
      return false // Database was tampered with directly
    }

    // 3. Ed25519 Cryptographic Verification of the stored token
    val (verified, _) = verifyTokenCryptographically(entity.activationToken, entity.deviceId)
    return verified
  }

  /**
   * Validates and applies an activation code entered by the student.
   */
  suspend fun activateWithCode(inputCode: String): ActivationResult = withContext(Dispatchers.IO) {
    val cleanCode = inputCode.trim()
    val localDeviceId = getOrCreateDeviceId()

    if (cleanCode.isBlank()) {
      return@withContext ActivationResult.Error(
        messageOm = "Koodii mirkaneessaa galchaa (Please enter activation code)",
        technicalReason = "Empty code"
      )
    }

    val (isValid, parsed) = verifyTokenCryptographically(cleanCode, localDeviceId)
    if (!isValid || parsed == null) {
      val failReason = parsed?.optString("error") ?: "Invalid token"
      val userMsg = when {
        failReason.contains("DEVICE_MISMATCH") ->
          "Koodiin kun moobaayila kanaaf hin ta'u. (Device ID mismatch)"
        failReason.contains("EXPIRED") ->
          "Koodiin kun yeroon isaa darbeera. (Activation code has expired)"
        else ->
          "Koodiin mirkaneessaa sirrii miti. (Invalid code or bad signature)"
      }
      return@withContext ActivationResult.Error(userMsg, failReason)
    }

    val plan = parsed.optString("p", "LIFETIME")
    val expiry = if (parsed.has("x")) parsed.getLong("x") else null
    val currentNow = System.currentTimeMillis() / 1000L

    // Compute hardware-backed HMAC
    val stateHmac = computeStateHmac(localDeviceId, plan, expiry, cleanCode)

    // Save in Room
    val entity = ActivationEntity(
      id = "primary_activation",
      deviceId = localDeviceId,
      isActivated = true,
      plan = plan,
      expiryTimestamp = expiry,
      activationToken = cleanCode,
      activatedAt = currentNow,
      lastKnownTimestamp = currentNow
    )
    database.activationDao().saveActivation(entity)

    // Save in Keystore-backed SharedPreferences
    prefs.edit()
      .putString(KEY_ACTIVATION_HMAC, stateHmac)
      .putLong(KEY_LAST_TIMESTAMP, currentNow)
      .apply()

    ActivationResult.Success(plan, expiry)
  }

  /**
   * Pure Ed25519 verification without external services.
   */
  fun verifyTokenCryptographically(token: String, expectedDeviceId: String): Pair<Boolean, JSONObject?> {
    val parts = token.trim().split(".")
    if (parts.size != 3 || parts[0] != "LMF1") {
      return Pair(false, JSONObject().put("error", "FORMAT_ERROR"))
    }

    val payloadBytes = try {
      decodeBase64Url(parts[1])
    } catch (_: Exception) {
      return Pair(false, JSONObject().put("error", "PAYLOAD_DECODE_ERROR"))
    }

    val sigBytes = try {
      decodeBase64Url(parts[2])
    } catch (_: Exception) {
      return Pair(false, JSONObject().put("error", "SIGNATURE_DECODE_ERROR"))
    }

    if (sigBytes.size != 64) {
      return Pair(false, JSONObject().put("error", "SIGNATURE_LENGTH_ERROR"))
    }

    // Ed25519 cryptographic verification against public key
    val signatureOk = Ed25519Verifier.verify(
      publicKey = ActivationConfig.PUBLIC_KEY_BYTES,
      message = payloadBytes,
      signature = sigBytes
    )

    if (!signatureOk) {
      return Pair(false, JSONObject().put("error", "BAD_SIGNATURE"))
    }

    val json = try {
      JSONObject(String(payloadBytes, Charsets.UTF_8))
    } catch (_: Exception) {
      return Pair(false, JSONObject().put("error", "JSON_PARSE_ERROR"))
    }

    val targetDevice = json.optString("d", "").trim().uppercase()
    if (targetDevice != expectedDeviceId.trim().uppercase()) {
      return Pair(false, JSONObject().put("error", "DEVICE_MISMATCH"))
    }

    // Expiration check
    if (json.has("x")) {
      val exp = json.getLong("x")
      val currentNow = System.currentTimeMillis() / 1000L
      if (currentNow > exp) {
        return Pair(false, JSONObject().put("error", "EXPIRED"))
      }
    }

    return Pair(true, json)
  }

  companion object {
    private const val PREFS_NAME = "lamif_activation_secure_prefs"
    private const val KEY_DEVICE_ID = "device_id"
    private const val KEY_ACTIVATION_HMAC = "activation_hmac"
    private const val KEY_LAST_TIMESTAMP = "last_known_timestamp"

    private const val KEYSTORE_PROVIDER = "AndroidKeyStore"
    private const val KEYSTORE_ALIAS = "lamif_activation_protection_key"

    fun decodeBase64Url(str: String): ByteArray {
      return try {
        java.util.Base64.getUrlDecoder().decode(str)
      } catch (_: Throwable) {
        var s = str.replace('-', '+').replace('_', '/')
        val padding = (4 - s.length % 4) % 4
        for (i in 0 until padding) s += "="
        Base64.decode(s, Base64.DEFAULT)
      }
    }
  }

  /**
   * Generates or retrieves an HMAC key from the hardware Android Keystore
   * to protect local activation state against SQLite editor tampering.
   */
  private fun getOrCreateHmacKey(): SecretKey {
    try {
      val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER)
      keyStore.load(null)

      if (keyStore.containsAlias(KEYSTORE_ALIAS)) {
        val entry = keyStore.getEntry(KEYSTORE_ALIAS, null) as? KeyStore.SecretKeyEntry
        if (entry != null) return entry.secretKey
      }

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_HMAC_SHA256, KEYSTORE_PROVIDER)
        val spec = KeyGenParameterSpec.Builder(
          KEYSTORE_ALIAS,
          KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
        ).build()
        keyGenerator.init(spec)
        return keyGenerator.generateKey()
      }
    } catch (_: Exception) {
      // Keystore unavailable in standard test runner or legacy emulator
    }

    // Fallback deterministic local key derived from device ID salt
    val salt = getOrCreateDeviceId() + "LamifOfflineSalt"
    val digest = MessageDigest.getInstance("SHA-256").digest(salt.toByteArray(Charsets.UTF_8))
    return SecretKeySpec(digest, "HmacSHA256")
  }

  private fun computeStateHmac(deviceId: String, plan: String, expiry: Long?, token: String): String {
    val message = "$deviceId:$plan:${expiry ?: 0}:$token"
    val mac = Mac.getInstance("HmacSHA256")
    mac.init(getOrCreateHmacKey())
    val bytes = mac.doFinal(message.toByteArray(Charsets.UTF_8))
    return try {
      java.util.Base64.getEncoder().encodeToString(bytes)
    } catch (_: Throwable) {
      Base64.encodeToString(bytes, Base64.NO_WRAP)
    }
  }
}
