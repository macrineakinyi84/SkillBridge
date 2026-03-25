/**
 * Auth middleware: explicit allow, default deny.
 *
 * Two-layer model for admin: authenticate first, then authorise.
 * - protect (authenticate): are you logged in? (valid JWT)
 * - requireAdmin: is req.user.role === 'admin'?
 * - requireVerified: is req.user.isVerified === true? (block until email verified)
 *
 * JWT payload must include: { userId, role, isVerified } so requireAdmin and requireVerified work.
 *
 * Test with:
 *   curl https://yourapi.com/api/users                    → expect 401
 *   curl -H "Authorization: Bearer invalid" .../api/users  → expect 401
 *   curl -H "Authorization: Bearer VALID_JWT" .../api/users → expect 200
 *   curl .../api/admin/users (no auth)                    → expect 401
 *   curl -H "Authorization: Bearer USER_JWT" .../api/admin/users → expect 403
 */

const jwt = require('jsonwebtoken');
const { getJwtSecret } = require('../config/env');

/**
 * Protect route: only allow access when a valid JWT is present.
 * Default deny — we only call next() after successful verification.
 * Alias: authenticate (use this name on admin routes so grep finds it).
 *
 * @param {import('express').Request} req
 * @param {import('express').Response} res
 * @param {import('express').NextFunction} next
 */
function protect(req, res, next) {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.startsWith('Bearer ')
    ? authHeader.slice(7)
    : null;

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const secret = getJwtSecret();
    const decoded = jwt.verify(token, secret);
    req.user = decoded;
    next(); // explicit allow — only reached when token is valid
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

/** Alias for protect — use "authenticate" in admin routes so route-audit grep finds protected routes. */
const authenticate = protect;

/**
 * Authorise: allow only admin. Must be used after authenticate.
 * Apply: router.delete('/admin/users/:id', authenticate, requireAdmin, deleteUser);
 */
function requireAdmin(req, res, next) {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden — admin only' });
  }
  next();
}

/**
 * Block access until email is verified. Use after authenticate.
 * JWT payload must include isVerified (set at login from user.isVerified).
 * Apply: router.post('/assessments/submit', authenticate, requireVerified, submitAssessment);
 */
function requireVerified(req, res, next) {
  if (!req.user?.isVerified) {
    return res.status(403).json({
      error: 'Email not verified. Check your inbox for the OTP.',
    });
  }
  next();
}

/**
 * Authorise: allow only employer. Must be used after authenticate.
 * Apply: router.get('/api/employer/dashboard', authenticate, requireEmployer, ...);
 */
function requireEmployer(req, res, next) {
  if (req.user?.role !== 'employer') {
    return res.status(403).json({ error: 'Forbidden — employer only' });
  }
  next();
}

/**
 * Authorise: allow only student. Must be used after authenticate.
 * Apply: router.get('/api/students/me/dashboard', authenticate, requireStudent, ...);
 */
function requireStudent(req, res, next) {
  if (req.user?.role !== 'student') {
    return res.status(403).json({ error: 'Forbidden — student only' });
  }
  next();
}

module.exports = {
  protect,
  authenticate,
  requireAdmin,
  requireVerified,
  requireEmployer,
  requireStudent,
};
