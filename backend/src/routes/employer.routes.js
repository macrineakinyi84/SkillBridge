/**
 * Employer-only API. Every route must use authenticate AND requireEmployer.
 * A student JWT must never reach these endpoints (403 Forbidden).
 */
const express = require('express');
const { authenticate, requireEmployer } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');
const employerController = require('../modules/employer/employer.controller');

const router = express.Router();

/**
 * GET /api/employer/dashboard
 * Employer dashboard stats and recent applicants (placeholder until Job/Application models).
 */
router.get('/dashboard', authenticate, requireEmployer, asyncHandler(async (req, res) => {
  const employerId = req.user.userId;
  const data = await employerController.getDashboard(employerId);
  return res.json({ success: true, data });
}));

/**
 * GET /api/employer/candidates/:userId
 * Candidate profile — what employers see (student profile, skills, assessment summary).
 * 404 if userId is not a student or not found.
 */
router.get('/candidates/:userId', authenticate, requireEmployer, asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const profile = await employerController.getCandidateProfile(userId);
  if (!profile) {
    return res.status(404).json({ success: false, error: { message: 'Candidate not found' } });
  }
  return res.json({ success: true, data: profile });
}));

/**
 * GET /api/employer/talent-pool
 * Talent pool search. Query: county, categoryId, q (search), limit, offset.
 */
router.get('/talent-pool', authenticate, requireEmployer, asyncHandler(async (req, res) => {
  const { county, categoryId, q, limit, offset } = req.query;
  const data = await employerController.getTalentPoolSearch({
    county,
    categoryId,
    q,
    limit,
    offset,
  });
  return res.json({ success: true, data });
}));

module.exports = router;
