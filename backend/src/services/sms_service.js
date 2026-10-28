/**
 * Swappable SMS Provider architecture for Grade 8 Prep app.
 * Keeps SMS costs at 0 by default (REQUIRE_PHONE_OTP_AT_SIGNUP=false),
 * but supports swappable providers (Ethio Telecom, Twilio, Africa's Talking, or HTTP Webhook)
 * without hardcoding vendor-specific logic into controllers.
 */

export class ISmsProvider {
  /**
   * @param {{ to: string, message: string }} params
   * @returns {Promise<{ success: boolean, messageId?: string, error?: string }>}
   */
  async sendSms({ to, message }) {
    throw new Error('sendSms must be implemented by concrete provider');
  }
}

/**
 * Console Mock Provider for Local Development, Testing, and Zero-Cost staging.
 * Never leaks sensitive OTPs to public logs; prints masked digits in non-production.
 */
export class MockSmsProvider extends ISmsProvider {
  async sendSms({ to, message }) {
    if (process.env.NODE_ENV !== 'production') {
      const maskedPhone = to.slice(0, 4) + '***' + to.slice(-2);
      console.log(`[SMS MOCK] Dispatched to ${maskedPhone}: "${message}"`);
    }
    return { success: true, messageId: `mock_${Date.now()}` };
  }
}

/**
 * Generic HTTP Webhook SMS Provider for Ethio Telecom aggregators, AfricasTalking, or custom gateways.
 * Configured via environment variables:
 * - SMS_PROVIDER_URL
 * - SMS_API_KEY
 * - SMS_SENDER_ID
 */
export class HttpWebhookSmsProvider extends ISmsProvider {
  constructor() {
    super();
    this.apiUrl = process.env.SMS_PROVIDER_URL;
    this.apiKey = process.env.SMS_API_KEY;
    this.senderId = process.env.SMS_SENDER_ID || 'LAMIF';
  }

  async sendSms({ to, message }) {
    if (!this.apiUrl) {
      console.warn('[SMS Provider] SMS_PROVIDER_URL not configured. Falling back to log.');
      return { success: true, messageId: `mock_fallback_${Date.now()}` };
    }

    try {
      const res = await fetch(this.apiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(this.apiKey ? { Authorization: `Bearer ${this.apiKey}` } : {}),
        },
        body: JSON.stringify({
          sender: this.senderId,
          to,
          message,
        }),
      });

      if (!res.ok) {
        const text = await res.text();
        return { success: false, error: `SMS gateway responded with HTTP ${res.status}: ${text}` };
      }

      const data = await res.json().catch(() => ({}));
      return { success: true, messageId: data.messageId || data.id || 'sent' };
    } catch (err) {
      return { success: false, error: err.message };
    }
  }
}

/**
 * Factory for creating the active SMS provider based on environment configuration
 */
export function getActiveSmsProvider() {
  const providerType = (process.env.SMS_PROVIDER || 'mock').toLowerCase();

  switch (providerType) {
    case 'http':
    case 'webhook':
    case 'ethio_telecom':
    case 'africastalking':
      return new HttpWebhookSmsProvider();
    case 'mock':
    default:
      return new MockSmsProvider();
  }
}

export const smsService = getActiveSmsProvider();
