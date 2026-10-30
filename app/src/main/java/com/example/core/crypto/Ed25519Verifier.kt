package com.example.core.crypto

import java.math.BigInteger
import java.security.MessageDigest

/**
 * Pure-Kotlin, zero-dependency Ed25519 signature verifier compliant with RFC 8032.
 * Works offline across all Android versions (API 24 to 36+) without native libraries.
 */
object Ed25519Verifier {

  // Prime field: p = 2^255 - 19
  private val P: BigInteger = BigInteger.valueOf(2).pow(255).subtract(BigInteger.valueOf(19))

  // Group order: q = 2^252 + 27742317777372353535851937790883648493
  private val Q: BigInteger = BigInteger.valueOf(2).pow(252).add(
    BigInteger("27742317777372353535851937790883648493")
  )

  // Curve constant: d = -121665 / 121666 mod p
  private val D: BigInteger = BigInteger.valueOf(-121665)
    .multiply(BigInteger.valueOf(121666).modInverse(P))
    .mod(P)

  // Square root of -1 mod p
  private val I: BigInteger = BigInteger.valueOf(2).modPow(P.subtract(BigInteger.ONE).divide(BigInteger.valueOf(4)), P)

  // Base point B
  private val BY: BigInteger = BigInteger.valueOf(4).multiply(BigInteger.valueOf(5).modInverse(P)).mod(P)
  private val BX: BigInteger = xRecover(BY)
  private val B = Point(BX.mod(P), BY.mod(P))

  data class Point(val x: BigInteger, val y: BigInteger)

  private fun inv(z: BigInteger): BigInteger = z.modInverse(P)

  private fun xRecover(y: BigInteger): BigInteger {
    val y2 = y.multiply(y).mod(P)
    val xx = y2.subtract(BigInteger.ONE).multiply(inv(D.multiply(y2).add(BigInteger.ONE))).mod(P)
    var x = xx.modPow(P.add(BigInteger.valueOf(3)).divide(BigInteger.valueOf(8)), P)
    if (x.multiply(x).subtract(xx).mod(P) != BigInteger.ZERO) {
      x = x.multiply(I).mod(P)
    }
    if (x.testBit(0)) {
      x = P.subtract(x)
    }
    return x
  }

  private fun edwardsAdd(p1: Point, p2: Point): Point {
    val x1 = p1.x
    val y1 = p1.y
    val x2 = p2.x
    val y2 = p2.y

    val dX1X2Y1Y2 = D.multiply(x1).multiply(x2).multiply(y1).multiply(y2).mod(P)
    val numX = x1.multiply(y2).add(x2.multiply(y1)).mod(P)
    val denX = BigInteger.ONE.add(dX1X2Y1Y2).mod(P)
    val x3 = numX.multiply(inv(denX)).mod(P)

    val numY = y1.multiply(y2).add(x1.multiply(x2)).mod(P)
    val denY = BigInteger.ONE.subtract(dX1X2Y1Y2).mod(P)
    val y3 = numY.multiply(inv(denY)).mod(P)

    return Point(x3, y3)
  }

  private fun scalarMult(p: Point, e: BigInteger): Point {
    var exp = e
    if (exp == BigInteger.ZERO) return Point(BigInteger.ZERO, BigInteger.ONE)
    var q = scalarMult(p, exp.shiftRight(1))
    q = edwardsAdd(q, q)
    if (exp.testBit(0)) {
      q = edwardsAdd(q, p)
    }
    return q
  }

  private fun decodePoint(bytes: ByteArray): Point? {
    if (bytes.size != 32) return null
    var y = bytesToPositiveBigIntLE(bytes)
    val signBit = (bytes[31].toInt() and 0xFF) ushr 7
    y = y.clearBit(255) // Clear the high bit

    var x = xRecover(y)
    val xBit = if (x.testBit(0)) 1 else 0
    if (signBit != xBit) {
      x = P.subtract(x)
    }
    return Point(x, y)
  }

  private fun bytesToPositiveBigIntLE(bytes: ByteArray): BigInteger {
    val reversed = ByteArray(bytes.size + 1) // extra zero byte ensures positive BigInt
    for (i in bytes.indices) {
      reversed[bytes.size - 1 - i + 1] = bytes[i]
    }
    return BigInteger(reversed)
  }

  private fun sha512(data: ByteArray): ByteArray {
    val md = MessageDigest.getInstance("SHA-512")
    return md.digest(data)
  }

  /**
   * Verifies an Ed25519 signature against public key and message.
   *
   * @param publicKey 32-byte raw Ed25519 public key
   * @param message UTF-8 raw message bytes
   * @param signature 64-byte raw Ed25519 signature (R + S)
   * @return true if signature is valid and authentic, false otherwise
   */
  fun verify(publicKey: ByteArray, message: ByteArray, signature: ByteArray): Boolean {
    if (signature.size != 64 || publicKey.size != 32) return false

    val rBytes = signature.copyOfRange(0, 32)
    val sBytes = signature.copyOfRange(32, 64)

    val rPoint = try { decodePoint(rBytes) } catch (_: Exception) { null } ?: return false
    val aPoint = try { decodePoint(publicKey) } catch (_: Exception) { null } ?: return false

    val s = bytesToPositiveBigIntLE(sBytes)
    if (s >= Q) return false

    val hashInput = ByteArray(32 + 32 + message.size)
    System.arraycopy(rBytes, 0, hashInput, 0, 32)
    System.arraycopy(publicKey, 0, hashInput, 32, 32)
    System.arraycopy(message, 0, hashInput, 64, message.size)

    val h = sha512(hashInput)
    val k = bytesToPositiveBigIntLE(h).mod(Q)

    val sB = scalarMult(B, s)
    val kA = scalarMult(aPoint, k)
    val rKa = edwardsAdd(rPoint, kA)

    return sB.x == rKa.x && sB.y == rKa.y
  }
}
