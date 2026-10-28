/**
 * In-memory sliding window rate limiter tailored for a single VPS deployment (no Redis required).
 * Protects against SMS-bombing, brute-force PIN guessing, and credential stuffing.
 */

class InMemoryRateLimiter {
  constructor() {
    this.buckets = new Map();

    // Auto-clean expired buckets every 10 minutes to prevent memory leaks
    setInterval(() => this.cleanup(), 10 * 60 * 1000).unref();
  }

  /**
   * Checks if an action is allowed for a given key.
   * @param {string} key - Composite identifier (e.g. `login:phone:0911223344` or `login:ip:1.2.3.4`)
   * @param {number} maxAttempts - Allowed operations in the window
   * @param {number} windowMs - Time window in milliseconds
   * @returns {{ allowed: boolean, remaining: number, retryAfterSeconds: number }}
   */
  check(key, maxAttempts, windowMs) {
    const now = Date.now();
    let record = this.buckets.get(key);

    if (!record) {
      record = { timestamps: [] };
      this.buckets.set(key, record);
    }

    // Filter out timestamps outside the active window
    record.timestamps = record.timestamps.filter((ts) => now - ts < windowMs);

    if (record.timestamps.length >= maxAttempts) {
      const oldest = record.timestamps[0];
      const retryAfterSeconds = Math.ceil((oldest + windowMs - now) / 1000);
      return {
        allowed: false,
        remaining: 0,
        retryAfterSeconds: Math.max(1, retryAfterSeconds),
      };
    }

    return {
      allowed: true,
      remaining: maxAttempts - record.timestamps.length,
      retryAfterSeconds: 0,
    };
  }

  /**
   * Consumes one attempt for the key
   */
  hit(key, maxAttempts, windowMs) {
    const status = this.check(key, maxAttempts, windowMs);
    if (status.allowed) {
      const record = this.buckets.get(key);
      record.timestamps.push(Date.now());
      status.remaining -= 1;
    }
    return status;
  }

  /**
   * Resets counter for a key upon successful action (e.g. correct login)
   */
  reset(key) {
    this.buckets.delete(key);
  }

  cleanup() {
    const now = Date.now();
    const maxRetention = 24 * 60 * 60 * 1000; // 24 hours
    for (const [key, record] of this.buckets.entries()) {
      record.timestamps = record.timestamps.filter((ts) => now - ts < maxRetention);
      if (record.timestamps.length === 0) {
        this.buckets.delete(key);
      }
    }
  }
}

export const rateLimiter = new InMemoryRateLimiter();

/**
 * Express middleware factory for per-IP and per-Phone rate limiting
 */
export function createRateLimitMiddleware({
  prefix,
  maxAttempts,
  windowMs,
  extractPhone = (req) => req.body?.phone || req.query?.phone,
  customMessageOm = 'Yaalii baay\'ee taasisaniittu. Maaloo xiqqoo eegaatii deebisaa yaalaa.',
  customMessageEn = 'Too many attempts. Please try again later.',
}) {
  return (req, res, next) => {
    const ip = req.headers['x-forwarded-for']?.split(',')[0]?.trim() || req.socket.remoteAddress || 'unknown_ip';
    const rawPhone = extractPhone(req);
    const phone = rawPhone ? rawPhone.toString().replace(/\s+/g, '') : null;

    // Check IP limit
    const ipKey = `${prefix}:ip:${ip}`;
    const ipStatus = rateLimiter.check(ipKey, maxAttempts * 2, windowMs); // IP limit allows multiple users behind NAT
    if (!ipStatus.allowed) {
      res.setHeader('Retry-After', ipStatus.retryAfterSeconds);
      return res.status(429).json({
        success: false,
        message: `${customMessageOm} (${customMessageEn})`,
        retryAfterSeconds: ipStatus.retryAfterSeconds,
      });
    }

    // Check Phone limit if available
    if (phone) {
      const phoneKey = `${prefix}:phone:${phone}`;
      const phoneStatus = rateLimiter.check(phoneKey, maxAttempts, windowMs);
      if (!phoneStatus.allowed) {
        res.setHeader('Retry-After', phoneStatus.retryAfterSeconds);
        return res.status(429).json({
          success: false,
          message: `${customMessageOm} (${customMessageEn})`,
          retryAfterSeconds: phoneStatus.retryAfterSeconds,
        });
      }
    }

    // Attach tracker to req for controller to hit or reset
    req.rateLimitTracker = {
      recordHit: () => {
        rateLimiter.hit(ipKey, maxAttempts * 2, windowMs);
        if (phone) rateLimiter.hit(`${prefix}:phone:${phone}`, maxAttempts, windowMs);
      },
      resetHits: () => {
        if (phone) rateLimiter.reset(`${prefix}:phone:${phone}`);
      },
    };

    next();
  };
}
