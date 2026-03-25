const express = require('express');

const { authenticate, requireVerified } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');
const scoring = require('../modules/assessment/scoring.service');
const assessmentService = require('../modules/assessment/assessment.service');

const router = express.Router();

/**
 * List assessment categories.
 * GET /api/assessments/categories
 */
router.get('/categories', asyncHandler(async (req, res) => {
  const categories = assessmentService.getCategories();
  return res.json({ success: true, data: categories });
}));

/**
 * Get questions for a category (for quiz).
 * GET /api/assessments/categories/:categoryId/questions
 */
router.get('/categories/:categoryId/questions', asyncHandler(async (req, res) => {
  const { categoryId } = req.params;
  if (!categoryId) {
    return res.status(400).json({ success: false, error: { message: 'categoryId is required' } });
  }
  const questions = assessmentService.getQuestions(categoryId);
  return res.json({ success: true, data: questions });
}));

/**
 * Score an assessment attempt (no persistence).
 * POST /api/assessments/score
 *
 * Body:
 * {
 *   "answers": { "q1": 2, "q2": 0 },
 *   "questions": [{ "id":"q1","difficulty":"easy","correctIndex":2 }, ...]
 * }
 */
router.post('/score', authenticate, requireVerified, asyncHandler(async (req, res) => {
  const { answers, questions } = req.body || {};

  if (!answers || typeof answers !== 'object') {
    return res.status(400).json({ success: false, error: { message: 'answers must be an object' } });
  }
  if (!Array.isArray(questions) || questions.length === 0) {
    return res.status(400).json({ success: false, error: { message: 'questions must be a non-empty array' } });
  }

  const { rawScore, maxPossibleScore } = scoring.calculateRawScore(answers, questions);
  const score = scoring.normaliseScore(rawScore, maxPossibleScore);
  const tier = scoring.assignTier(score);

  return res.json({
    success: true,
    data: {
      rawScore,
      maxPossibleScore,
      score,
      tier,
    },
  });
}));

/**
 * Submit assessment (persists score, awards XP, checks badges).
 * POST /api/assessments/submit
 * Body: { "categoryId": "digital-literacy", "answers": { "q1": 2, "q2": 0 } }
 */
router.post('/submit', authenticate, requireVerified, asyncHandler(async (req, res) => {
  const userId = req.user.userId;
  const { categoryId, answers } = req.body || {};
  if (!categoryId || typeof categoryId !== 'string') {
    return res.status(400).json({ success: false, error: { message: 'categoryId is required' } });
  }
  if (!answers || typeof answers !== 'object') {
    return res.status(400).json({ success: false, error: { message: 'answers must be an object' } });
  }
  const result = await assessmentService.submitAssessment(userId, categoryId, answers);
  return res.json({ success: true, data: result });
}));

module.exports = router;

