import { Router } from 'express';
import { receiptUpload } from '../middleware/upload.js';
import {
  registerWithPin,
  requestSignupOtp,
  loginWithPin,
  refreshToken,
  adminGeneratePinReset,
  resetPinWithCode,
  changePin,
  deleteAccount,
  registerPayment,
  getPaymentStatus,
  adminVerifyPayment,
} from '../controllers/auth.controller.js';
import { createRateLimitMiddleware } from '../middleware/rate_limiter.js';

const router = Router();

// Rate limiters for authentication endpoints
const loginLimiter = createRateLimitMiddleware({
  prefix: 'login',
  maxAttempts: 5,
  windowMs: 15 * 60 * 1000, // 15 minutes
  customMessageOm: 'PIN dogoggoraa yeroo baay\'ee yaaltaniittu. Daaqiiqaa 15 eegaa.',
  customMessageEn: 'Too many failed login attempts. Please wait 15 minutes.',
});

const otpLimiter = createRateLimitMiddleware({
  prefix: 'signup_otp',
  maxAttempts: 2,
  windowMs: 60 * 60 * 1000, // 1 hour per phone (stops SMS-bombing)
  customMessageOm: 'Gaaffiin SMS koodii heddummaateera. Sa\'aatii 1 eegaa.',
  customMessageEn: 'Too many OTP requests. Please try again in 1 hour.',
});

const resetLimiter = createRateLimitMiddleware({
  prefix: 'pin_reset',
  maxAttempts: 3,
  windowMs: 15 * 60 * 1000, // 15 minutes
  customMessageOm: 'Yaaliin koodii deebisaa heddummaateera.',
  customMessageEn: 'Too many reset attempts.',
});

const deleteLimiter = createRateLimitMiddleware({
  prefix: 'account_deletion',
  maxAttempts: 3,
  windowMs: 60 * 60 * 1000, // 1 hour
  customMessageOm: 'Yaaliin haqiisa herregaa heddummaateera.',
  customMessageEn: 'Too many account deletion attempts.',
});

// ============================================================================
// Core PIN Authentication & Session Routes
// ============================================================================

// POST /api/v1/auth/request-signup-otp - Dispatches OTP if REQUIRE_PHONE_OTP_AT_SIGNUP=true
router.post('/request-signup-otp', otpLimiter, requestSignupOtp);

// POST /api/v1/auth/register - Signup once with 6-digit PIN, creates account + tokens
router.post('/register', registerWithPin);

// POST /api/v1/auth/login - Online PIN login (new device/reinstall) with anti-timing protection
router.post('/login', loginLimiter, loginWithPin);

// POST /api/v1/auth/refresh-token - Refresh short-lived access token
router.post('/refresh-token', refreshToken);

// POST /api/v1/auth/admin/generate-reset-code - Admin-generated 15-min temporary reset code
router.post('/admin/generate-reset-code', adminGeneratePinReset);

// POST /api/v1/auth/reset-pin - Student submits single-use reset code + new 6-digit PIN
router.post('/reset-pin', resetLimiter, resetPinWithCode);

// POST /api/v1/auth/change-pin - In-app PIN change requiring current PIN verification
router.post('/change-pin', changePin);

// DELETE & POST /api/v1/auth/delete-account - Permanent account deletion (requires Phone + PIN)
router.delete('/delete-account', deleteLimiter, deleteAccount);
router.post('/delete-account', deleteLimiter, deleteAccount);

// ============================================================================
// Payment Flow Routes (Existing functionality preserved)
// ============================================================================

// POST /api/v1/auth/register-payment - Accepts Multer file upload 'receipt' + form fields
router.post('/register-payment', receiptUpload.single('receipt'), registerPayment);

// GET /api/v1/auth/payment-status - Checks verification status by phone or userId
router.get('/payment-status', getPaymentStatus);

// POST /api/v1/auth/admin-verify - Administrative verification / rejection
router.post('/admin-verify', adminVerifyPayment);

export default router;
