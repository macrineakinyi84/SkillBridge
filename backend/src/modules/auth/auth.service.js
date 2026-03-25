const jwt = require('jsonwebtoken');

const { getJwtSecret } = require('../../config/env');
const { generateOtp, defaultExpiry } = require('../../lib/otp');
const store = require('./auth.store');

function issueJwtForUser(user) {
  const payload = {
    userId: user.id,
    role: user.role,
    isVerified: user.isVerified,
    email: user.email,
  };
  const token = jwt.sign(payload, getJwtSecret(), { expiresIn: '7d' });
  return { token, user: payload };
}

async function requestEmailOtp(email, roleOptional) {
  const user = await store.getOrCreateUserByEmail(email, roleOptional);
  if (!user) {
    const err = new Error('email is required');
    err.status = 400;
    throw err;
  }
  const otp = generateOtp();
  const expiresAt = defaultExpiry();
  await store.setOtpForEmail(user.email, otp, expiresAt);
  return { user, otp, expiresAt };
}

async function verifyEmailOtp(email, otp) {
  const user = await store.getOrCreateUserByEmail(email);
  if (!user) {
    const err = new Error('email is required');
    err.status = 400;
    throw err;
  }
  if (!otp || String(otp).trim().length !== 6) {
    const err = new Error('otp must be 6 digits');
    err.status = 400;
    throw err;
  }

  const result = await store.verifyOtpForEmail(user.email, String(otp).trim());
  if (!result.ok) {
    const err = new Error(
      result.reason === 'expired'
        ? 'OTP expired'
        : result.reason === 'missing'
          ? 'No OTP requested'
          : 'Invalid OTP'
    );
    err.status = 400;
    throw err;
  }

  const verifiedUser = await store.markVerified(user.email);
  return issueJwtForUser(verifiedUser);
}

async function login(email) {
  const user = await store.getOrCreateUserByEmail(email);
  if (!user) {
    const err = new Error('email is required');
    err.status = 400;
    throw err;
  }
  if (!user.isVerified) {
    const err = new Error('Email not verified');
    err.status = 403;
    err.code = 'EMAIL_NOT_VERIFIED';
    throw err;
  }
  return issueJwtForUser(user);
}

module.exports = {
  requestEmailOtp,
  verifyEmailOtp,
  login,
  issueJwtForUser,
};

