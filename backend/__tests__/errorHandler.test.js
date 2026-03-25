const { asyncHandler, globalErrorHandler } = require('../src/middleware/errorHandler');

describe('errorHandler', () => {
  describe('asyncHandler', () => {
    it('forwards req, res to the handler and returns its result', async () => {
      const handler = asyncHandler(async (req, res) => {
        res.json({ ok: true });
      });
      const req = {};
      const res = { json: jest.fn() };
      const next = jest.fn();
      await handler(req, res, next);
      expect(res.json).toHaveBeenCalledWith({ ok: true });
      expect(next).not.toHaveBeenCalled();
    });

    it('calls next with error when handler throws', async () => {
      const err = new Error('boom');
      const handler = asyncHandler(async () => {
        throw err;
      });
      const req = {};
      const res = {};
      const next = jest.fn();
      await handler(req, res, next);
      expect(next).toHaveBeenCalledWith(err);
    });

    it('calls next with rejection when handler rejects', async () => {
      const err = new Error('rejected');
      const handler = asyncHandler(async () => {
        return Promise.reject(err);
      });
      const next = jest.fn();
      await handler({}, {}, next);
      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe('globalErrorHandler', () => {
    it('returns 500 and INTERNAL_ERROR without leaking message in production', () => {
      process.env.NODE_ENV = 'production';
      const err = new Error('internal detail');
      const req = {};
      const res = { status: jest.fn().mockReturnThis(), json: jest.fn() };
      const next = jest.fn();
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
      globalErrorHandler(err, req, res, next);
      expect(res.status).toHaveBeenCalledWith(500);
      expect(res.json).toHaveBeenCalledWith({
        success: false,
        error: { code: 'INTERNAL_ERROR', message: 'Something went wrong' },
      });
      consoleSpy.mockRestore();
      process.env.NODE_ENV = 'test';
    });

    it('uses err.status when present', () => {
      const err = new Error('bad request');
      err.status = 400;
      const res = { status: jest.fn().mockReturnThis(), json: jest.fn() };
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
      globalErrorHandler(err, {}, res, () => {});
      expect(res.status).toHaveBeenCalledWith(400);
      consoleSpy.mockRestore();
    });
  });
});
