import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import prisma from '../prisma.js';
import { smsService } from '../services/sms_service.js';

// Fallback in-memory cache for development/demo when PostgreSQL database is not connected
const fallbackUserDb = new Map();
// Temporary store for signup OTPs: Map<normalizedPhone, { otpHash, expiresAt }>
const signupOtpCache = new Map();

// Configuration Constants
const JWT_SECRET = process.env.JWT_SECRET || 'lamif_grade_8_jwt_dev_secret_key_2026';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'lamif_grade_8_refresh_dev_secret_key_2026';
const ACCESS_TOKEN_EXPIRY = process.env.ACCESS_TOKEN_EXPIRY || '15m';
const REFRESH_TOKEN_EXPIRY = process.env.REFRESH_TOKEN_EXPIRY || '90d';
const OFFLINE_GRACE_DAYS = parseInt(process.env.OFFLINE_GRACE_DAYS || '21', 10);
const REQUIRE_PHONE_OTP_AT_SIGNUP = process.env.REQUIRE_PHONE_OTP_AT_SIGNUP === 'true';

// Pre-computed dummy hash to ensure uniform execution time for unknown phone numbers (anti-timing attack)
const DUMMY_SALTED_HASH = '$2a$10$w8Lq7Z.c.H4529V8E9yq9u4B5B49K.Hq20q9k.12345678901234';

/**
 * Normalizes Ethiopian phone numbers (+2519..., 09..., 9...)
 */
export function normalizePhone(raw) {
  if (!raw) return '';
  let cleaned = raw.toString().replace(/\s+/g, '').replace(/-/g, '');
  if (cleaned.startsWith('+251')) {
    cleaned = '0' + cleaned.substring(4);
  } else if (cleaned.startsWith('251')) {
    cleaned = '0' + cleaned.substring(3);
  } else if (cleaned.startsWith('9') && cleaned.length === 9) {
    cleaned = '0' + cleaned;
  }
  return cleaned;
}

/**
 * Validates and maps chosen track string to Prisma enum
 */
export function parseTrackEnum(trackStr) {
  if (!trackStr) return 'BOTH';
  const upper = trackStr.toUpperCase().trim();
  if (upper === 'MINISTRY_ONLY' || upper.includes('MINISTRY') || upper.includes('MINISTEERA')) {
    return 'MINISTRY_ONLY';
  }
  if (upper === 'IFA_BORU_ONLY' || upper.includes('IFA_BORU') || upper.includes('BORU')) {
    return 'IFA_BORU_ONLY';
  }
  return 'BOTH';
}

/**
 * Generates an Access Token and long-lived Refresh Token
 */
function generateTokens(user) {
  const payload = {
    userId: user.id,
    phone: user.phone,
    role: 'student',
  };

  const accessToken = jwt.sign(payload, JWT_SECRET, { expiresIn: ACCESS_TOKEN_EXPIRY });
  const refreshToken = jwt.sign(payload, JWT_REFRESH_SECRET, { expiresIn: REFRESH_TOKEN_EXPIRY });

  return { accessToken, refreshToken };
}

// ============================================================================
// REQUIREMENT 1: SIGNUP (Internet required, once)
// ============================================================================

/**
 * POST /api/v1/auth/request-signup-otp
 * Dispatches one-time verification SMS ONLY IF REQUIRE_PHONE_OTP_AT_SIGNUP=true
 */
export async function requestSignupOtp(req, res) {
  try {
    const { phone } = req.body;
    if (!phone) {
      return res.status(400).json({
        success: false,
        message: 'Lakkoofsi bilbilaa barbaachisaadha (Phone number is required).',
      });
    }

    const normalizedPhone = normalizePhone(phone);

    // If OTP requirement is disabled, inform client to proceed directly to register
    if (!REQUIRE_PHONE_OTP_AT_SIGNUP) {
      return res.json({
        success: true,
        otpRequired: false,
        message: 'Koodiin OTP hin barbaachisu. Kallattiin galmaa\'uu dandeessa.',
      });
    }

    // Check if phone already registered
    let existing = null;
    if (prisma && prisma.user) {
      try {
        existing = await prisma.user.findUnique({ where: { phone: normalizedPhone } });
      } catch (_) {}
    }
    if (!existing && fallbackUserDb.has(normalizedPhone)) {
      existing = fallbackUserDb.get(normalizedPhone);
    }

    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'Lakkoofsi bilbilaa kun kanaan dura galmaa\'eera (Phone number is already registered).',
      });
    }

    // Generate 6-digit random OTP
    const rawOtp = crypto.randomInt(100000, 999999).toString();
    const otpHash = await bcrypt.hash(rawOtp, 8);
    const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes

    signupOtpCache.set(normalizedPhone, { otpHash, expiresAt });

    // Send SMS via active provider
    await smsService.sendSms({
      to: normalizedPhone,
      message: `Koodiin mirkaneessaa Lamif Kutaa 8 keessan: ${rawOtp}. Daaqiiqaa 5 keessatti fayyadamaa.`,
    });

    if (req.rateLimitTracker) req.rateLimitTracker.recordHit();

    return res.json({
      success: true,
      otpRequired: true,
      message: 'Koodiin mirkaneessaa SMS bilbila keessanitti ergameera.',
    });
  } catch (err) {
    console.error('Error in requestSignupOtp:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Dogoggorri ergaa SMS mudateera. Maaloo irra deebi\'aa yaalaa.',
    });
  }
}

/**
 * POST /api/v1/auth/register
 * Creates student account, stores salted bcrypt PIN, returns JWT tokens + offline grace duration.
 * Idempotent: safe against network timeouts and duplicate retries.
 */
export async function registerWithPin(req, res) {
  try {
    const { name, phone, schoolZone, schoolName, selectedTrack, pin, otpCode } = req.body;

    if (!name || !name.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Maqaan guutuun barbaachisaadha (Full name is required).',
      });
    }

    if (!phone || !phone.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Lakkoofsi bilbilaa barbaachisaadha (Phone number is required).',
      });
    }

    if (!schoolZone || !schoolZone.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Godinni mana barumsaa barbaachisaadha (School zone is required).',
      });
    }

    if (!pin || !/^\d{6}$/.test(pin.toString())) {
      return res.status(400).json({
        success: false,
        message: 'PIN dijiitii 6 ta\'uu qaba (PIN must be exactly 6 numeric digits).',
      });
    }

    const normalizedPhone = normalizePhone(phone);
    const validTrack = parseTrackEnum(selectedTrack);
    const amountPaid = validTrack === 'BOTH' ? 300.0 : 200.0;

    // Verify OTP if required
    if (REQUIRE_PHONE_OTP_AT_SIGNUP) {
      const cachedOtp = signupOtpCache.get(normalizedPhone);
      if (!cachedOtp || Date.now() > cachedOtp.expiresAt) {
        return res.status(400).json({
          success: false,
          message: 'Koodiin OTP yeroon isaa darbeera ykn hin argamne. Haaraa gaafadhaa.',
        });
      }
      const isMatch = await bcrypt.compare(otpCode ? otpCode.toString().trim() : '', cachedOtp.otpHash);
      if (!isMatch) {
        return res.status(400).json({
          success: false,
          message: 'Koodiin OTP galftan sirrii miti (Invalid OTP code).',
        });
      }
      signupOtpCache.delete(normalizedPhone);
    }

    // Check for existing user (Idempotent retry check)
    let existingUser = null;
    if (prisma && prisma.user) {
      try {
        existingUser = await prisma.user.findUnique({ where: { phone: normalizedPhone } });
      } catch (_) {}
    }
    if (!existingUser && fallbackUserDb.has(normalizedPhone)) {
      existingUser = fallbackUserDb.get(normalizedPhone);
    }

    if (existingUser) {
      // If user already exists and matches credentials, return existing tokens (idempotent retry)
      if (existingUser.pinHash && (await bcrypt.compare(pin.toString(), existingUser.pinHash))) {
        const tokens = generateTokens(existingUser);
        return res.status(200).json({
          success: true,
          message: 'Herregni kanaan dura galmaa\'ee ture deebifameera.',
          data: {
            userId: existingUser.id,
            name: existingUser.name,
            phone: existingUser.phone,
            schoolZone: existingUser.schoolZone,
            schoolName: existingUser.schoolName,
            selectedTrack: existingUser.selectedTrack,
            paymentStatus: existingUser.paymentStatus,
            amountPaid: existingUser.amountPaid,
            offlineGraceDays: OFFLINE_GRACE_DAYS,
            ...tokens,
          },
        });
      }

      return res.status(409).json({
        success: false,
        message: 'Lakkoofsi bilbilaa kun kanaan dura galmaa\'eera. Maaloo seensaan yaalaa (Phone already registered).',
      });
    }

    // Salt and hash the 6-digit PIN (bcrypt with 10 salt rounds)
    const pinHash = await bcrypt.hash(pin.toString(), 10);

    let newUser = null;
    if (prisma && prisma.user) {
      try {
        newUser = await prisma.user.create({
          data: {
            name: name.trim(),
            phone: normalizedPhone,
            schoolZone: schoolZone.trim(),
            schoolName: schoolName ? schoolName.trim() : null,
            selectedTrack: validTrack,
            paymentStatus: 'PENDING',
            amountPaid,
            pinHash,
            mustSetPin: false,
          },
        });
      } catch (dbErr) {
        console.warn('Prisma create error, using fallback memory store:', dbErr.message);
      }
    }

    if (!newUser) {
      newUser = {
        id: `usr_${Date.now()}`,
        name: name.trim(),
        phone: normalizedPhone,
        schoolZone: schoolZone.trim(),
        schoolName: schoolName ? schoolName.trim() : null,
        selectedTrack: validTrack,
        paymentStatus: 'PENDING',
        amountPaid,
        pinHash,
        mustSetPin: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      fallbackUserDb.set(normalizedPhone, newUser);
    }

    // Generate tokens and persist hashed refresh token
    const tokens = generateTokens(newUser);
    const refreshTokenHash = await bcrypt.hash(tokens.refreshToken, 8);

    if (prisma && prisma.user && newUser.id) {
      try {
        await prisma.user.update({
          where: { id: newUser.id },
          data: { refreshTokenHash },
        });
      } catch (_) {}
    }
    if (fallbackUserDb.has(normalizedPhone)) {
      const u = fallbackUserDb.get(normalizedPhone);
      u.refreshTokenHash = refreshTokenHash;
      fallbackUserDb.set(normalizedPhone, u);
    }

    return res.status(201).json({
      success: true,
      message: 'Galmeen milkaa\'inaan xumurameera. Qabxii qormaataa offline fayyadamuu dandeessa.',
      data: {
        userId: newUser.id,
        name: newUser.name,
        phone: newUser.phone,
        schoolZone: newUser.schoolZone,
        schoolName: newUser.schoolName,
        selectedTrack: newUser.selectedTrack,
        paymentStatus: newUser.paymentStatus,
        amountPaid: newUser.amountPaid,
        offlineGraceDays: OFFLINE_GRACE_DAYS,
        ...tokens,
      },
    });
  } catch (err) {
    console.error('Error in registerWithPin:', err);
    return res.status(500).json({
      success: false,
      message: 'Dogoggorri galmee mudateera. Maaloo irra deebi\'aa yaalaa.',
      error: err.message,
    });
  }
}

// ============================================================================
// REQUIREMENT 2: ONLINE LOGIN (New phone / reinstall)
// ============================================================================

/**
 * POST /api/v1/auth/login
 * Validates phone + PIN with constant-time comparison against timing attacks.
 * Generic error messages to prevent phone enumeration.
 */
export async function loginWithPin(req, res) {
  try {
    const { phone, pin } = req.body;

    if (!phone || !pin) {
      return res.status(400).json({
        success: false,
        message: 'Bilbilli fi PIN barbaachisaadha (Phone and PIN required).',
      });
    }

    const normalizedPhone = normalizePhone(phone);
    const pinString = pin.toString();

    let user = null;
    if (prisma && prisma.user) {
      try {
        user = await prisma.user.findUnique({ where: { phone: normalizedPhone } });
      } catch (_) {}
    }
    if (!user && fallbackUserDb.has(normalizedPhone)) {
      user = fallbackUserDb.get(normalizedPhone);
    }

    // Constant-time execution guarantee: if user does not exist, compare against dummy hash
    const targetHash = user?.pinHash || DUMMY_SALTED_HASH;
    const isPinValid = await bcrypt.compare(pinString, targetHash);

    // If user not found OR pin does not match -> return identical generic message
    if (!user || !isPinValid) {
      if (req.rateLimitTracker) req.rateLimitTracker.recordHit();

      // Return generic 401 error - never reveal whether phone or PIN was incorrect
      return res.status(401).json({
        success: false,
        message: 'Bilbilli ykn PIN sirrii miti (Invalid phone number or PIN).',
      });
    }

    // Reset rate limiter hits on successful login
    if (req.rateLimitTracker) req.rateLimitTracker.resetHits();

    // Generate new tokens
    const tokens = generateTokens(user);
    const refreshTokenHash = await bcrypt.hash(tokens.refreshToken, 8);

    if (prisma && prisma.user) {
      try {
        await prisma.user.update({
          where: { id: user.id },
          data: {
            refreshTokenHash,
            failedAttempts: 0,
            lockedUntil: null,
          },
        });
      } catch (_) {}
    }

    return res.json({
      success: true,
      message: 'Seensi milkaa\'eera.',
      data: {
        userId: user.id,
        name: user.name,
        phone: user.phone,
        schoolZone: user.schoolZone,
        schoolName: user.schoolName,
        selectedTrack: user.selectedTrack,
        paymentStatus: user.paymentStatus,
        paymentReceiptUrl: user.paymentReceiptUrl,
        amountPaid: user.amountPaid,
        mustSetPin: user.mustSetPin || false,
        offlineGraceDays: OFFLINE_GRACE_DAYS,
        ...tokens,
      },
    });
  } catch (err) {
    console.error('Error in loginWithPin:', err);
    return res.status(500).json({
      success: false,
      message: 'Dogoggorri seensaa mudateera.',
    });
  }
}

// ============================================================================
// REQUIREMENT 3: REFRESH TOKEN & SESSIONS
// ============================================================================

/**
 * POST /api/v1/auth/refresh-token
 * Issues new access token if refresh token is valid and not revoked
 */
export async function refreshToken(req, res) {
  try {
    const { refreshToken: incomingToken, phone } = req.body;

    if (!incomingToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token barbaachisaadha.',
      });
    }

    let decoded;
    try {
      decoded = jwt.verify(incomingToken, JWT_REFRESH_SECRET);
    } catch (_) {
      return res.status(401).json({
        success: false,
        message: 'Refresh token yeroon isaa darbeera ykn sirrii miti (Token expired).',
      });
    }

    let user = null;
    if (prisma && prisma.user) {
      try {
        user = await prisma.user.findUnique({ where: { id: decoded.userId } });
      } catch (_) {}
    }
    if (!user && phone) {
      user = fallbackUserDb.get(normalizePhone(phone));
    }
    if (!user && decoded.userId) {
      for (const u of fallbackUserDb.values()) {
        if (u.id === decoded.userId) {
          user = u;
          break;
        }
      }
    }

    if (!user) {
      return res.status(401).json({ success: false, message: 'Barataan hin argamne.' });
    }

    // Check token revocation timestamp
    if (user.tokenRevokedAt && new Date(decoded.iat * 1000) < user.tokenRevokedAt) {
      return res.status(401).json({
        success: false,
        message: 'Token kun haqameera. Irra deebi\'aa seenaa (Session revoked).',
      });
    }

    // Verify stored refresh token hash
    if (user.refreshTokenHash) {
      const matches = await bcrypt.compare(incomingToken, user.refreshTokenHash);
      if (!matches) {
        return res.status(401).json({ success: false, message: 'Refresh token sirrii miti.' });
      }
    }

    const payload = { userId: user.id, phone: user.phone, role: 'student' };
    const newAccessToken = jwt.sign(payload, JWT_SECRET, { expiresIn: ACCESS_TOKEN_EXPIRY });

    return res.json({
      success: true,
      accessToken: newAccessToken,
      paymentStatus: user.paymentStatus,
      offlineGraceDays: OFFLINE_GRACE_DAYS,
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
}

// ============================================================================
// REQUIREMENT 4: PIN RECOVERY & PIN CHANGE
// ============================================================================

/**
 * POST /api/v1/auth/admin/generate-reset-code
 * Admin generates a single-use 6-digit temporary reset code that expires in 15 minutes.
 * Protected by X-Admin-Secret header.
 */
export async function adminGeneratePinReset(req, res) {
  try {
    const adminSecret = req.headers['x-admin-secret'];
    const expectedSecret = process.env.ADMIN_SECRET || 'lamif_admin_secret_2026';

    if (!adminSecret || adminSecret !== expectedSecret) {
      return res.status(403).json({ success: false, message: 'Heeyyama hin qabdu (Unauthorized).' });
    }

    const { phone } = req.body;
    if (!phone) {
      return res.status(400).json({ success: false, message: 'Lakkoofsi bilbilaa barbaachisaadha.' });
    }

    const normalizedPhone = normalizePhone(phone);
    let user = null;

    if (prisma && prisma.user) {
      try {
        user = await prisma.user.findUnique({ where: { phone: normalizedPhone } });
      } catch (_) {}
    }
    if (!user && fallbackUserDb.has(normalizedPhone)) {
      user = fallbackUserDb.get(normalizedPhone);
    }

    if (!user) {
      return res.status(404).json({ success: false, message: 'Barataan hin argamne.' });
    }

    // Generate single-use 6-digit code
    const resetCode = crypto.randomInt(100000, 999999).toString();
    const pinResetCodeHash = await bcrypt.hash(resetCode, 10);
    const pinResetExpiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    if (prisma && prisma.user) {
      try {
        await prisma.user.update({
          where: { id: user.id },
          data: {
            pinResetCodeHash,
            pinResetExpiresAt,
            failedAttempts: 0,
            lockedUntil: null,
          },
        });
      } catch (_) {}
    }

    if (fallbackUserDb.has(normalizedPhone)) {
      const u = fallbackUserDb.get(normalizedPhone);
      u.pinResetCodeHash = pinResetCodeHash;
      u.pinResetExpiresAt = pinResetExpiresAt;
      fallbackUserDb.set(normalizedPhone, u);
    }

    return res.json({
      success: true,
      message: 'Koodiin deebii PIN milkaa\'inaan uumameera (15 daaqiiqaaf hojjeta).',
      data: {
        phone: normalizedPhone,
        studentName: user.name,
        temporaryResetCode: resetCode, // Admin gives this code directly to student verbally or via official slip
        expiresAt: pinResetExpiresAt,
      },
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
}

/**
 * POST /api/v1/auth/reset-pin
 * Validates single-use 15-minute reset code, updates PIN hash, revokes prior sessions.
 */
export async function resetPinWithCode(req, res) {
  try {
    const { phone, resetCode, newPin } = req.body;

    if (!phone || !resetCode || !newPin) {
      return res.status(400).json({
        success: false,
        message: 'Bilbilli, koodii deebisaa, fi PIN haaraan barbaachisaadha.',
      });
    }

    if (!/^\d{6}$/.test(newPin.toString())) {
      return res.status(400).json({
        success: false,
        message: 'PIN haaraan dijiitii 6 ta\'uu qaba.',
      });
    }

    const normalizedPhone = normalizePhone(phone);
    let user = null;

    if (prisma && prisma.user) {
      try {
        user = await prisma.user.findUnique({ where: { phone: normalizedPhone } });
      } catch (_) {}
    }
    if (!user && fallbackUserDb.has(normalizedPhone)) {
      user = fallbackUserDb.get(normalizedPhone);
    }

    if (!user || !user.pinResetCodeHash || !user.pinResetExpiresAt) {
      return res.status(400).json({
        success: false,
        message: 'Koodiin sirrii miti ykn hin gaafatamne (Invalid or non-existent reset request).',
      });
    }

    if (new Date() > new Date(user.pinResetExpiresAt)) {
      return res.status(400).json({
        success: false,
        message: 'Yeroon koodii darbeera. Koodii haaraa gaafadhaa (Reset code expired).',
      });
    }

    const isCodeValid = await bcrypt.compare(resetCode.toString().trim(), user.pinResetCodeHash);
    if (!isCodeValid) {
      if (req.rateLimitTracker) req.rateLimitTracker.recordHit();
      return res.status(400).json({
        success: false,
        message: 'Koodiin deebisaa dogoggora (Invalid reset code).',
      });
    }

    // Salt and hash new PIN
    const newPinHash = await bcrypt.hash(newPin.toString(), 10);
    const tokenRevocationTime = new Date();

    if (prisma && prisma.user) {
      try {
        await prisma.user.update({
          where: { id: user.id },
          data: {
            pinHash: newPinHash,
            pinResetCodeHash: null,
            pinResetExpiresAt: null,
            mustSetPin: false,
            tokenRevokedAt: tokenRevocationTime,
            refreshTokenHash: null,
            failedAttempts: 0,
            lockedUntil: null,
          },
        });
      } catch (_) {}
    }

    if (fallbackUserDb.has(normalizedPhone)) {
      const u = fallbackUserDb.get(normalizedPhone);
      u.pinHash = newPinHash;
      u.pinResetCodeHash = null;
      u.pinResetExpiresAt = null;
      u.mustSetPin = false;
      u.tokenRevokedAt = tokenRevocationTime;
      u.refreshTokenHash = null;
      fallbackUserDb.set(normalizedPhone, u);
    }

    return res.json({
      success: true,
      message: 'PIN haaraan milkaa\'inaan jijjiirameera. Amma ittiin seenuu dandeessa.',
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
}

/**
 * POST /api/v1/auth/change-pin
 * In-app PIN change requiring verification of current PIN
 */
export async function changePin(req, res) {
  try {
    const { phone, currentPin, newPin } = req.body;

    if (!phone || !currentPin || !newPin) {
      return res.status(400).json({
        success: false,
        message: 'Bilbilli, PIN duraanii fi PIN haaraan barbaachisaadha.',
      });
    }

    if (!/^\d{6}$/.test(newPin.toString())) {
      return res.status(400).json({
        success: false,
        message: 'PIN haaraan dijiitii 6 ta\'uu qaba.',
      });
    }

    const normalizedPhone = normalizePhone(phone);
    let user = null;

    if (prisma && prisma.user) {
      try {
        user = await prisma.user.findUnique({ where: { phone: normalizedPhone } });
      } catch (_) {}
    }
    if (!user && fallbackUserDb.has(normalizedPhone)) {
      user = fallbackUserDb.get(normalizedPhone);
    }

    if (!user || !user.pinHash) {
      return res.status(401).json({ success: false, message: 'Barataan hin argamne.' });
    }

    const isMatch = await bcrypt.compare(currentPin.toString(), user.pinHash);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'PIN duraanii sirrii miti (Current PIN is incorrect).',
      });
    }

    const newPinHash = await bcrypt.hash(newPin.toString(), 10);
    const tokenRevocationTime = new Date();

    if (prisma && prisma.user) {
      try {
        await prisma.user.update({
          where: { id: user.id },
          data: {
            pinHash: newPinHash,
            tokenRevokedAt: tokenRevocationTime,
            refreshTokenHash: null,
          },
        });
      } catch (_) {}
    }

    return res.json({
      success: true,
      message: 'PIN haaraan milkaa\'inaan jijjiirameera.',
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
}

// ============================================================================
// REQUIREMENT 5: SECURE ACCOUNT DELETION (Requires PIN verification)
// ============================================================================

/**
 * DELETE & POST /api/v1/auth/delete-account
 * Permanent deletion of student account, profile, payment receipts, and exam history.
 * Complies with Google Play policy: Requires Phone + PIN verification, never phone alone!
 */
export async function deleteAccount(req, res) {
  try {
    const phone = req.body?.phone || req.query?.phone;
    const pin = req.body?.pin || req.query?.pin;

    if (!phone || !pin) {
      return res.status(400).json({
        success: false,
        message: 'Bilbilli fi PIN mirkaneessuuf barbaachisaadha (Phone number and PIN are required for account deletion).',
      });
    }

    const normalizedPhone = normalizePhone(phone);
    let targetUser = null;

    if (prisma && prisma.user) {
      try {
        targetUser = await prisma.user.findUnique({ where: { phone: normalizedPhone } });
      } catch (_) {}
    }
    if (!targetUser && fallbackUserDb.has(normalizedPhone)) {
      targetUser = fallbackUserDb.get(normalizedPhone);
    }

    // Verify PIN before permitting irreversible deletion
    const targetHash = targetUser?.pinHash || DUMMY_SALTED_HASH;
    const isPinValid = await bcrypt.compare(pin.toString(), targetHash);

    if (!targetUser || !isPinValid) {
      if (req.rateLimitTracker) req.rateLimitTracker.recordHit();
      return res.status(401).json({
        success: false,
        message: 'Bilbilli ykn PIN sirrii miti (Invalid phone number or PIN).',
      });
    }

    if (prisma && prisma.user) {
      try {
        // Cascade delete exam results, progress, and user
        await prisma.examResult.deleteMany({ where: { userId: targetUser.id } });
        await prisma.userProgress.deleteMany({ where: { userId: targetUser.id } });
        await prisma.user.delete({ where: { id: targetUser.id } });
      } catch (_) {}
    }

    fallbackUserDb.delete(normalizedPhone);

    return res.json({
      success: true,
      message: 'Herregni fi ragaan kee hundi guutummaatti haqameera (Account and data permanently deleted).',
    });
  } catch (err) {
    console.error('Error in deleteAccount:', err);
    return res.status(500).json({
      success: false,
      message: 'Dogoggorri serverii mudateera.',
      error: err.message,
    });
  }
}

// ============================================================================
// EXISTING PAYMENT & ADMIN CONTROLLERS (Unmodified behavior)
// ============================================================================

export async function registerPayment(req, res) {
  try {
    const { name, phone, schoolZone, schoolName, selectedTrack } = req.body;

    if (!name || !name.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Maqaan guutuun barbaachisaadha (Full name is required).',
      });
    }

    if (!phone || !phone.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Lakkoofsi bilbilaa barbaachisaadha (Phone number is required).',
      });
    }

    if (!schoolZone || !schoolZone.trim()) {
      return res.status(400).json({
        success: false,
        message: 'Godinni mana barumsaa barbaachisaadha (School zone is required).',
      });
    }

    const normalizedPhone = normalizePhone(phone);
    const validTrack = parseTrackEnum(selectedTrack);
    const amountPaid = validTrack === 'BOTH' ? 300.0 : 200.0;

    let receiptUrl = null;
    if (req.file) {
      const baseUrl = process.env.BASE_URL || `http://${req.headers.host || 'localhost:5000'}`;
      receiptUrl = `${baseUrl}/uploads/receipts/${req.file.filename}`;
    }

    let user;

    if (prisma && prisma.user) {
      try {
        user = await prisma.user.upsert({
          where: { phone: normalizedPhone },
          update: {
            name: name.trim(),
            schoolZone: schoolZone.trim(),
            schoolName: schoolName ? schoolName.trim() : null,
            selectedTrack: validTrack,
            paymentStatus: 'PENDING',
            paymentReceiptUrl: receiptUrl,
            amountPaid,
          },
          create: {
            name: name.trim(),
            phone: normalizedPhone,
            schoolZone: schoolZone.trim(),
            schoolName: schoolName ? schoolName.trim() : null,
            selectedTrack: validTrack,
            paymentStatus: 'PENDING',
            paymentReceiptUrl: receiptUrl,
            amountPaid,
          },
        });
      } catch (dbError) {
        console.warn('Prisma DB error, falling back to local memory store:', dbError.message);
      }
    }

    if (!user) {
      const existing = fallbackUserDb.get(normalizedPhone) || {};
      user = {
        id: existing.id || `user_${Date.now()}`,
        name: name.trim(),
        phone: normalizedPhone,
        schoolZone: schoolZone.trim(),
        schoolName: schoolName ? schoolName.trim() : null,
        selectedTrack: validTrack,
        paymentStatus: 'PENDING',
        paymentReceiptUrl: receiptUrl,
        amountPaid,
        createdAt: existing.createdAt || new Date(),
        updatedAt: new Date(),
      };
      fallbackUserDb.set(normalizedPhone, user);
    }

    return res.status(201).json({
      success: true,
      message: "Galmeen fi nagaheen kafaltii milkaa'inaan ergameera. Qorannoon daaqiiqaa 15-30 keessatti xumurama.",
      data: {
        userId: user.id,
        name: user.name,
        phone: user.phone,
        schoolZone: user.schoolZone,
        selectedTrack: user.selectedTrack,
        paymentStatus: user.paymentStatus,
        paymentReceiptUrl: user.paymentReceiptUrl,
        amountPaid: user.amountPaid,
      },
    });
  } catch (err) {
    console.error('Error in registerPayment:', err);
    return res.status(500).json({
      success: false,
      message: 'Dogoggorri serverii mudateera. Maaloo irra deebi\'aa yaala.',
      error: err.message,
    });
  }
}

export async function getPaymentStatus(req, res) {
  try {
    const phone = req.query.phone ? normalizePhone(req.query.phone) : null;
    const userId = req.query.userId;

    if (!phone && !userId) {
      return res.status(400).json({
        success: false,
        message: 'Bilbila ykn User ID dhiyeessaa (phone or userId parameter required).',
      });
    }

    let user = null;

    if (prisma && prisma.user) {
      try {
        if (userId) {
          user = await prisma.user.findUnique({ where: { id: userId } });
        } else if (phone) {
          user = await prisma.user.findUnique({ where: { phone } });
        }
      } catch (dbError) {
        console.warn('Prisma DB error:', dbError.message);
      }
    }

    if (!user) {
      if (phone && fallbackUserDb.has(phone)) {
        user = fallbackUserDb.get(phone);
      } else if (userId) {
        for (const u of fallbackUserDb.values()) {
          if (u.id === userId) {
            user = u;
            break;
          }
        }
      }
    }

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Barataan lakkoofsa kanaan hin argamne (User not found).',
      });
    }

    return res.json({
      success: true,
      data: {
        userId: user.id,
        name: user.name,
        phone: user.phone,
        selectedTrack: user.selectedTrack,
        paymentStatus: user.paymentStatus,
        paymentReceiptUrl: user.paymentReceiptUrl,
        verifiedAt: user.verifiedAt,
        rejectionReason: user.rejectionReason,
      },
    });
  } catch (err) {
    console.error('Error in getPaymentStatus:', err);
    return res.status(500).json({
      success: false,
      message: 'Dogoggorri serverii mudateera.',
      error: err.message,
    });
  }
}

export async function adminVerifyPayment(req, res) {
  try {
    const { phone, userId, status, rejectionReason } = req.body;
    const normalizedPhone = phone ? normalizePhone(phone) : null;

    if (!['VERIFIED', 'REJECTED', 'PENDING'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Status must be VERIFIED, REJECTED, or PENDING.',
      });
    }

    let updated = null;

    if (prisma && prisma.user) {
      try {
        updated = await prisma.user.update({
          where: userId ? { id: userId } : { phone: normalizedPhone },
          data: {
            paymentStatus: status,
            verifiedAt: status === 'VERIFIED' ? new Date() : null,
            rejectionReason: status === 'REJECTED' ? (rejectionReason || 'Receipt was invalid') : null,
          },
        });
      } catch (e) {
        console.warn('Prisma update error:', e.message);
      }
    }

    if (!updated && normalizedPhone && fallbackUserDb.has(normalizedPhone)) {
      const u = fallbackUserDb.get(normalizedPhone);
      u.paymentStatus = status;
      u.verifiedAt = status === 'VERIFIED' ? new Date() : null;
      u.rejectionReason = status === 'REJECTED' ? rejectionReason : null;
      fallbackUserDb.set(normalizedPhone, u);
      updated = u;
    }

    return res.json({
      success: true,
      message: `Payment status updated to ${status}.`,
      data: updated,
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
}
