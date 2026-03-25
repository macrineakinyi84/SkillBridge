/**
 * Error handling: wrap async route handlers and register a global error handler.
 *
 * Layer 1: asyncHandler — catch async errors so they don't crash the process.
 * Layer 2: globalErrorHandler — must be the LAST middleware registered in Express.
 * Layer 3: process handlers — register in app entry (see processHandlers.js).
 */

/**
 * Wraps async route handlers so thrown errors and rejected promises are passed to next().
 * Use on every async route to avoid unhandled rejections.
 *
 * @example
 *   router.post('/assessments/submit', authenticate, asyncHandler(async (req, res) => {
 *     const result = await assessmentService.submit(req.body, req.user.userId);
 *     return res.json({ success: true, data: result });
 *   }));
 */
function asyncHandler(fn) {
  return (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
}

/**
 * Global Express error handler. Register last: app.use(globalErrorHandler).
 * Do not leak internal details to the client.
 */
function globalErrorHandler(err, req, res, next) {
  console.error('Unhandled error:', err.message);
  const status = err.status ?? err.statusCode ?? 500;
  res.status(status).json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: process.env.NODE_ENV === 'production' ? 'Something went wrong' : err.message,
    },
  });
}

module.exports = {
  asyncHandler,
  globalErrorHandler,
};
