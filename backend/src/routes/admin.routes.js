const express = require('express');

const { authenticate, requireAdmin } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');

const router = express.Router();

router.get('/ping', authenticate, requireAdmin, asyncHandler(async (req, res) => {
  res.json({ success: true, data: { ok: true } });
}));

module.exports = router;

