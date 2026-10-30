package com.example.core.crypto

/**
 * Public cryptographic configuration for offline activation.
 * Contains ONLY the public key. The private key remains secure in the offline admin tool.
 */
object ActivationConfig {
  /**
   * 32-byte Ed25519 public key in HEX format.
   * Generated from admin_tool/keygen.py.
   */
  const val PUBLIC_KEY_HEX = "0843f9bbe4c3d9a2bd509931ff837b7d0489ec4f8db418d09270f4e21fcdecea"

  val PUBLIC_KEY_BYTES: ByteArray by lazy {
    hexToBytes(PUBLIC_KEY_HEX)
  }

  fun hexToBytes(hex: String): ByteArray {
    val clean = hex.trim()
    val len = clean.length
    val data = ByteArray(len / 2)
    var i = 0
    while (i < len) {
      data[i / 2] = ((Character.digit(clean[i], 16) shl 4) + Character.digit(clean[i + 1], 16)).toByte()
      i += 2
    }
    return data
  }
}
