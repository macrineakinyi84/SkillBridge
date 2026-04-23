const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');

const { globalErrorHandler } = require('./middleware/errorHandler');
const routes = require('./routes');

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  message: { success: false, error: { message: 'Too many attempts. Try again later.' } },
  standardHeaders: true,
  legacyHeaders: false,
});

function createApp() {
  const app = express();

  // Trust Railway's load balancer so express-rate-limit can read the real
  // client IP from the X-Forwarded-For header instead of the proxy's IP.
  app.set('trust proxy', 1);

  app.use(cors());
  // Stripe webhook requires the raw body for signature verification.
  app.use('/api/billing/webhook', express.raw({ type: 'application/json' }));
  app.use(express.json({ limit: '1mb' }));
  app.use('/api/auth', authLimiter);

  app.get('/', (req, res) => {
    res.json({ service: 'skillbridge-backend', message: 'API is running. Use /health to check status. Auth: POST /api/auth/request-otp' });
  });

  app.get('/health', (req, res) => {
    res.json({ ok: true, service: 'skillbridge-backend', ts: new Date().toISOString() });
  });

  app.use('/api', routes);

  // Must be last.
  app.use(globalErrorHandler);

  return app;
}

module.exports = { createApp };

