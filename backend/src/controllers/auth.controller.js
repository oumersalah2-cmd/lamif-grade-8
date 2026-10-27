import prisma from '../prisma.js';

// In-memory fallback cache for development/demo when live PostgreSQL database is not connected
const fallbackUserDb = new Map();

/**
 * Normalizes Ethiopian phone numbers (+2519..., 09..., 9...)
 */
function normalizePhone(raw) {
  if (!raw) return '';
  let cleaned = raw.replace(/\s+/g, '').replace(/-/g, '');
  if (cleaned.startsWith('+251')) {
    cleaned = '0' + cleaned.substring(4);
  } else if (cleaned.startsWith('251')) {
    cleaned = '0' + cleaned.substring(3);
  }
  return cleaned;
}

/**
 * Validates and maps chosen track string to Prisma enum
 */
function parseTrackEnum(trackStr) {
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
 * POST /api/v1/auth/register-payment
 * Accepts multipart/form-data: name, phone, schoolZone, schoolName, selectedTrack, receipt (file)
 */
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
        // Upsert user in PostgreSQL via Prisma
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

    // In-memory fallback if database is offline or not configured yet
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

/**
 * GET /api/v1/auth/payment-status
 * Query parameters: phone or userId
 */
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

/**
 * POST /api/v1/auth/admin-verify
 * Endpoint for administrators or automated webhook to approve/reject payment
 */
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
