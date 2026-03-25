const jwt = require('jsonwebtoken');
const { protect, requireAdmin, requireVerified } = require('../src/middleware/auth');

function mockRes() {
  const res = {};
  res.status = jest.fn().mockReturnThis();
  res.json = jest.fn().mockReturnThis();
  return res;
}

function mockNext() {
  return jest.fn();
}

describe('auth middleware', () => {
  const secret = process.env.JWT_SECRET || 'test-secret-for-jest';

  describe('protect', () => {
    it('returns 401 when no Authorization header', () => {
      const req = { headers: {} };
      const res = mockRes();
      const next = mockNext();
      protect(req, res, next);
      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ error: 'No token provided' });
      expect(next).not.toHaveBeenCalled();
    });

    it('returns 401 when Authorization is not Bearer', () => {
      const req = { headers: { authorization: 'Basic xyz' } };
      const res = mockRes();
      const next = mockNext();
      protect(req, res, next);
      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ error: 'No token provided' });
      expect(next).not.toHaveBeenCalled();
    });

    it('returns 401 when token is invalid', () => {
      const req = { headers: { authorization: 'Bearer invalid-token' } };
      const res = mockRes();
      const next = mockNext();
      protect(req, res, next);
      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ error: 'Invalid or expired token' });
      expect(next).not.toHaveBeenCalled();
    });

    it('sets req.user and calls next when token is valid', () => {
      const payload = { userId: 'u1', role: 'student', isVerified: true };
      const token = jwt.sign(payload, secret, { expiresIn: '1h' });
      const req = { headers: { authorization: `Bearer ${token}` } };
      const res = mockRes();
      const next = mockNext();
      protect(req, res, next);
      expect(next).toHaveBeenCalled();
      expect(req.user).toBeDefined();
      expect(req.user.userId).toBe('u1');
      expect(req.user.role).toBe('student');
      expect(req.user.isVerified).toBe(true);
      expect(res.status).not.toHaveBeenCalled();
    });
  });

  describe('requireAdmin', () => {
    it('returns 403 when req.user.role is not admin', () => {
      const req = { user: { userId: 'u1', role: 'student' } };
      const res = mockRes();
      const next = mockNext();
      requireAdmin(req, res, next);
      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({ error: 'Forbidden — admin only' });
      expect(next).not.toHaveBeenCalled();
    });

    it('returns 403 when req.user is missing', () => {
      const req = {};
      const res = mockRes();
      const next = mockNext();
      requireAdmin(req, res, next);
      expect(res.status).toHaveBeenCalledWith(403);
      expect(next).not.toHaveBeenCalled();
    });

    it('calls next when req.user.role is admin', () => {
      const req = { user: { userId: 'a1', role: 'admin' } };
      const res = mockRes();
      const next = mockNext();
      requireAdmin(req, res, next);
      expect(next).toHaveBeenCalled();
      expect(res.status).not.toHaveBeenCalled();
    });
  });

  describe('requireVerified', () => {
    it('returns 403 when req.user.isVerified is not true', () => {
      const req = { user: { userId: 'u1', role: 'student', isVerified: false } };
      const res = mockRes();
      const next = mockNext();
      requireVerified(req, res, next);
      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({
        error: 'Email not verified. Check your inbox for the OTP.',
      });
      expect(next).not.toHaveBeenCalled();
    });

    it('returns 403 when req.user is missing', () => {
      const req = {};
      const res = mockRes();
      const next = mockNext();
      requireVerified(req, res, next);
      expect(res.status).toHaveBeenCalledWith(403);
      expect(next).not.toHaveBeenCalled();
    });

    it('calls next when req.user.isVerified is true', () => {
      const req = { user: { userId: 'u1', role: 'student', isVerified: true } };
      const res = mockRes();
      const next = mockNext();
      requireVerified(req, res, next);
      expect(next).toHaveBeenCalled();
      expect(res.status).not.toHaveBeenCalled();
    });
  });
});
