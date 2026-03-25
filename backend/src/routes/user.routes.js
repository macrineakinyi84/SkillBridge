const express = require('express');

const { authenticate } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

const router = express.Router();

// Response includes user: { userId, email, role, isVerified } from JWT for Flutter session/role.
router.get('/me', authenticate, asyncHandler(async (req, res) => {
  res.json({ success: true, data: { user: req.user } });
}));

module.exports = router;

