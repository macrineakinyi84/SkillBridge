const express = require('express');

const { authenticate } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');
const pdfService = require('../modules/portfolio/pdf.service');

const router = express.Router();

/**
 * Generate and download portfolio CV as PDF.
 * POST /api/portfolio/export-pdf
 * Body: { profile: { name, headline, email, phone?, county?, slug? }, skills: [], experience: [], education: [], projects: [], certifications: [] }
 */
router.post('/export-pdf', authenticate, asyncHandler(async (req, res) => {
  const data = req.body || {};
  const buffer = await pdfService.generatePortfolioPdf(data);
  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', 'attachment; filename="skillbridge-cv.pdf"');
  res.send(buffer);
}));

module.exports = router;
