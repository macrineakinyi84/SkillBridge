const express = require('express');
const jwt = require('jsonwebtoken');

const { asyncHandler } = require('../middleware/errorHandler');
const { getJwtSecret } = require('../config/env');
const authService = require('../modules/auth/auth.service');

const router = express.Router();

/**
 * Request an email OTP (verification code). Optional role for new users (student | employer).
 * POST /api/auth/request-otp
 * Body: { "email": "user@example.com", "role": "student"|"employer" (optional) }
 */
router.all('/request-otp', (req, res, next) => {
  if (req.method !== 'POST') {
    return res.status(405).json({
      success: false,
      error: { message: 'Method not allowed. Use POST with JSON body: { "email": "your@email.com" }' },
    });
  }
  next();
});
router.post('/request-otp', asyncHandler(async (req, res) => {
  const { email, role } = req.body || {};
  const { user, otp, expiresAt } = await authService.requestEmailOtp(email, role);

  // For this project we always include the OTP in the JSON response
  // so that it can be viewed from dev tools even in deployed environments.
  const includeOtp = true;
  return res.json({
    success: true,
    data: {
      email: user.email,
      expiresAt: expiresAt.toISOString(),
      ...(includeOtp ? { otp } : {}),
    },
  });
}));

/**
 * Verify an email OTP and mark user verified.
 * POST /api/auth/verify-otp
 * Body: { "email": "user@example.com", "otp": "123456" }
 * Response: { success, data: { token, user: { userId, email, role, isVerified } } } — Flutter can use data.user.role.
 */
router.post('/verify-otp', asyncHandler(async (req, res) => {
  const { email, otp } = req.body || {};
  const data = await authService.verifyEmailOtp(email, otp);
  return res.json({ success: true, data });
}));

/**
 * Login after verification.
 * POST /api/auth/login
 * Body: { "email": "user@example.com" }
 * Response: { success, data: { token, user: { userId, email, role, isVerified } } } — Flutter can use data.user.role.
 */
router.post('/login', asyncHandler(async (req, res) => {
  const { email } = req.body || {};
  const data = await authService.login(email);
  return res.json({ success: true, data });
}));

/**
 * Dev helper: mint a JWT without a DB.
 * POST /api/auth/dev-token
 * Body: { "userId": "u1", "role": "student"|"employer"|"admin", "isVerified": true }
 */
router.post('/dev-token', asyncHandler(async (req, res) => {
  const { userId, role, isVerified } = req.body || {};
  if (!userId || typeof userId !== 'string') {
    return res.status(400).json({ success: false, error: { message: 'userId is required' } });
  }

  const allowedRoles = ['student', 'employer', 'admin'];
  const payload = {
    userId,
    role: allowedRoles.includes(role) ? role : 'student',
    isVerified: Boolean(isVerified),
  };

  const token = jwt.sign(payload, getJwtSecret(), { expiresIn: '7d' });
  return res.json({ success: true, data: { token, user: payload } });
}));

module.exports = router;

