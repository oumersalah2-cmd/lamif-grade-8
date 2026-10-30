package com.example.activation

import com.example.core.crypto.ActivationConfig
import com.example.core.crypto.ActivationSecurityManager
import com.example.core.crypto.Ed25519Verifier
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Unit tests for offline Ed25519 activation verification,
 * device ID validation, tamper resistance, and expiration handling.
 */
class ActivationVerifierTest {

  private val targetDeviceId = "LMF-A1B2-C3D4-E5F6"
  private val wrongDeviceId = "LMF-9999-8888-7777"

  // Generated with admin_tool/activate.py using production Ed25519 private key
  private val validLifetimeToken =
    "LMF1.eyJkIjoiTE1GLUExQjItQzNENC1FNUY2IiwicCI6IkxJRkVUSU1FIiwidCI6MTc5MzM4OTM5MSwidiI6MX0.ijiSqNBlHUqibLKSRGwT3-4c6O5-T0_ltpBWOJRwxg_GtqOChoQPU1nciZTm9Vgn8KOx4JWZ1g1e-Uc-VeCtBw"

  private val validFutureExpiringToken =
    "LMF1.eyJkIjoiTE1GLUExQjItQzNENC1FNUY2IiwicCI6IkVYUElSSU5HIiwidCI6MTcwMDAwMDAwMCwidiI6MSwieCI6MjUwMDAwMDAwMH0.olt_Gc2Iy472-awnpOYaPPb6uGN2o75GdAbtQWoZ7kJwT7CbVSsEgrrD7dOQnogUreRHBGodVPwKqznvlXG0Bg"

  private val expiredToken =
    "LMF1.eyJkIjoiTE1GLUExQjItQzNENC1FNUY2IiwicCI6IkVYUElSSU5HIiwidCI6MTcwMDAwMDAwMCwidiI6MSwieCI6MTYwMDAwMDAwMH0.JwWHdI-UnktLWAreKMFzWnlPFDSAve0-XjLXfjSDeka65AHisbWyjHLnYZmT0C4gkbiFjNNSXmN7UkTrigEWCg"

  @Test
  fun testValidLifetimeCode_VerifiesSuccessfully() {
    val (isValid, payload) = verifyToken(validLifetimeToken, targetDeviceId)
    assertTrue("Valid lifetime token should verify successfully", isValid)
    assertNotNull(payload)
    assertEquals(targetDeviceId, payload?.optString("d"))
    assertEquals("LIFETIME", payload?.optString("p"))
  }

  @Test
  fun testValidExpiringCode_VerifiesSuccessfully() {
    val (isValid, payload) = verifyToken(validFutureExpiringToken, targetDeviceId)
    assertTrue("Valid future expiring token should verify successfully", isValid)
    assertNotNull(payload)
    assertEquals(targetDeviceId, payload?.optString("d"))
    assertEquals("EXPIRING", payload?.optString("p"))
    assertEquals(2500000000L, payload?.optLong("x"))
  }

  @Test
  fun testWrongDeviceId_Rejected() {
    val (isValid, payload) = verifyToken(validLifetimeToken, wrongDeviceId)
    assertFalse("Token must be rejected when Device ID does not match", isValid)
    assertNotNull(payload)
    assertEquals("DEVICE_MISMATCH", payload?.optString("error"))
  }

  @Test
  fun testTamperedPayload_Rejected() {
    // Altered payload: replace a character in the base64 payload
    val tamperedToken = validLifetimeToken.replace("TE1GLUExQjIt", "TE1GLUExQjIz")
    val (isValid, payload) = verifyToken(tamperedToken, targetDeviceId)
    assertFalse("Tampered token payload must fail cryptographic verification", isValid)
    assertEquals("BAD_SIGNATURE", payload?.optString("error"))
  }

  @Test
  fun testTamperedSignature_Rejected() {
    // Altered signature: replace last char
    val lastChar = validLifetimeToken.last()
    val replacement = if (lastChar == 'w') 'x' else 'w'
    val tamperedToken = validLifetimeToken.dropLast(1) + replacement

    val (isValid, payload) = verifyToken(tamperedToken, targetDeviceId)
    assertFalse("Tampered signature must fail verification", isValid)
    assertEquals("BAD_SIGNATURE", payload?.optString("error"))
  }

  @Test
  fun testExpiredCode_Rejected() {
    val (isValid, payload) = verifyToken(expiredToken, targetDeviceId)
    assertFalse("Expired token must be rejected", isValid)
    assertNotNull(payload)
    assertEquals("EXPIRED", payload?.optString("error"))
  }

  @Test
  fun testMalformedToken_Rejected() {
    val (isValid, payload) = verifyToken("NotAToken", targetDeviceId)
    assertFalse("Malformed token must be rejected", isValid)
    assertEquals("FORMAT_ERROR", payload?.optString("error"))
  }

  /**
   * Helper that tests the exact Ed25519 verification logic without requiring Android Context.
   */
  private fun verifyToken(token: String, expectedDeviceId: String): Pair<Boolean, org.json.JSONObject?> {
    val parts = token.trim().split(".")
    if (parts.size != 3 || parts[0] != "LMF1") {
      return Pair(false, org.json.JSONObject().put("error", "FORMAT_ERROR"))
    }

    val payloadBytes = try {
      ActivationSecurityManager.decodeBase64Url(parts[1])
    } catch (_: Exception) {
      return Pair(false, org.json.JSONObject().put("error", "PAYLOAD_DECODE_ERROR"))
    }

    val sigBytes = try {
      ActivationSecurityManager.decodeBase64Url(parts[2])
    } catch (_: Exception) {
      return Pair(false, org.json.JSONObject().put("error", "SIGNATURE_DECODE_ERROR"))
    }

    if (sigBytes.size != 64) {
      return Pair(false, org.json.JSONObject().put("error", "SIGNATURE_LENGTH_ERROR"))
    }

    val signatureOk = Ed25519Verifier.verify(
      publicKey = ActivationConfig.PUBLIC_KEY_BYTES,
      message = payloadBytes,
      signature = sigBytes
    )

    if (!signatureOk) {
      return Pair(false, org.json.JSONObject().put("error", "BAD_SIGNATURE"))
    }

    val json = try {
      org.json.JSONObject(String(payloadBytes, Charsets.UTF_8))
    } catch (_: Exception) {
      return Pair(false, org.json.JSONObject().put("error", "JSON_PARSE_ERROR"))
    }

    val targetDevice = json.optString("d", "").trim().uppercase()
    if (targetDevice != expectedDeviceId.trim().uppercase()) {
      return Pair(false, org.json.JSONObject().put("error", "DEVICE_MISMATCH"))
    }

    if (json.has("x")) {
      val exp = json.getLong("x")
      val currentNow = System.currentTimeMillis() / 1000L
      if (currentNow > exp) {
        return Pair(false, org.json.JSONObject().put("error", "EXPIRED"))
      }
    }

    return Pair(true, json)
  }
}
