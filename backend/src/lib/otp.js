/**
 * OTP generation for email verification. Never use Math.random() for security-sensitive values.
 *
 * Store in DB with expiry (e.g. 10 minutes) and mark used when consumed.
 * Example schema (Prisma): model OtpToken { id, userId, token, expiresAt, used, createdAt }
 *
 * When issuing JWT at login, include isVerified: user.isVerified so requireVerified middleware works.
 */

const crypto = require('crypto');

/** Length of numeric OTP (e.g. 6 digits). */
const OTP_LENGTH = 6;

/**
 * Generate a cryptographically secure numeric OTP.
 * @returns {string} e.g. "847291"
 */
function generateOtp() {
  return crypto.randomInt(10 ** (OTP_LENGTH - 1), 10 ** OTP_LENGTH - 1).toString();
}

/**
 * Default expiry for OTP (10 minutes). Use when creating OtpToken in DB.
 * @returns {Date}
 */
function defaultExpiry() {
  return new Date(Date.now() + 10 * 60 * 1000);
}

module.exports = {
  generateOtp,
  defaultExpiry,
  OTP_LENGTH,
};
