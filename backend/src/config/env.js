/**
 * Backend config from environment variables. Never hardcode secrets.
 *
 * Validate all required env vars at startup (before the server starts) so Railway
 * logs show exactly which variable is missing instead of failing mid-request.
 *
 * In your app entry (e.g. index.js or app.js):
 *   require('dotenv').config();
 *   const { validateRequiredEnv } = require('./src/config/env');
 *   validateRequiredEnv(); // process.exit(1) if any required var is missing
 */

/** Required env vars — server refuses to start if any are missing. Adjust for your stack. */
const REQUIRED_ENV = [
  'DATABASE_URL',
  'JWT_SECRET',
  // 'CLOUDINARY_API_KEY',   // add when using Cloudinary
  // 'FIREBASE_PROJECT_ID',  // add when using Firebase
  // 'SMTP_USER', 'SMTP_PASS', // add when sending email
];

function getStripeSecretKey() {
  const key = process.env.STRIPE_SECRET_KEY;
  if (!key || key.trim() === '') {
    throw new Error('STRIPE_SECRET_KEY is not set. Set it in .env or the environment.');
  }
  return key;
}

function getDatabaseUrl() {
  return process.env.DATABASE_URL || '';
}

function getJwtSecret() {
  const secret = process.env.JWT_SECRET;
  if (!secret || secret.trim() === '') {
    throw new Error('JWT_SECRET is not set. Set it in .env or the environment.');
  }
  return secret;
}

function getEnv(name, defaultValue = undefined) {
  const value = process.env[name];
  if (value !== undefined && value !== '') return value;
  return defaultValue;
}

/**
 * Validate required environment variables at startup. Call this before starting the server.
 * Exits process with 1 if any required var is missing — crash loudly at startup, not mid-request.
 */
function validateRequiredEnv(required = REQUIRED_ENV) {
  const missing = required.filter((key) => !process.env[key] || String(process.env[key]).trim() === '');
  if (missing.length > 0) {
    console.error('Missing required environment variables:', missing.join(', '));
    process.exit(1);
  }
}

module.exports = {
  getStripeSecretKey,
  getDatabaseUrl,
  getJwtSecret,
  getEnv,
  validateRequiredEnv,
  REQUIRED_ENV,
};
