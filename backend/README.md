# SkillBridge Backend

Node.js service modules (assessment, gamification, community, notifications, etc.).

## Secrets and environment variables

**Never hardcode API keys or secrets.**

1. Copy `.env.example` to `.env` and set your values.
2. Load `.env` at app startup, then **validate required vars** so the server refuses to start if config is wrong:
   ```js
   require('dotenv').config();
   const { validateRequiredEnv } = require('./src/config/env');
   validateRequiredEnv(); // process.exit(1) if any required var is missing
   ```
3. Use helpers from `src/config/env.js` (e.g. `getJwtSecret()`, `getDatabaseUrl()`). Adjust `REQUIRED_ENV` in that file for your stack.
4. Add `.env` to `.gitignore` and never commit it.

## Auth middleware (explicit allow, default deny)

Use `src/middleware/auth.js`:

- **protect** (alias **authenticate**): only calls `next()` when the JWT is valid; otherwise 401.
- **requireAdmin**: use after authenticate; returns 403 if `req.user.role !== 'admin'`.
- **requireVerified**: use after authenticate; returns 403 if `req.user.isVerified` is not true (block until email verified).

**Admin routes — apply both authenticate and requireAdmin:**

```js
const { authenticate, requireAdmin } = require('./src/middleware/auth');

router.delete('/admin/users/:id', authenticate, requireAdmin, deleteUser);
router.get('/admin/analytics', authenticate, requireAdmin, getAnalytics);
```

**JWT payload** should include `{ userId, role, isVerified }` so requireAdmin and requireVerified work.

**Test auth:**

```bash
# Must return 401
curl https://yourapi.com/api/users
curl -H "Authorization: Bearer invalidtoken" https://yourapi.com/api/users

# With valid JWT — 200; for /admin/* with non-admin JWT — 403
curl -H "Authorization: Bearer VALID_JWT" https://yourapi.com/api/users
```

## Error handling and process safety

- **asyncHandler**: wrap every async route so thrown errors go to the error handler — `src/middleware/errorHandler.js`.
- **Global error handler**: register last in Express — `app.use(globalErrorHandler)`.
- **Process handlers**: in app entry, first line — `require('./src/processHandlers');` (handles uncaughtException / unhandledRejection).

## Database and file paths

- **Prisma**: use the single client from `src/lib/prisma.js`. Never create `new PrismaClient()` inside route handlers. On Railway free tier, set `?connection_limit=5` in `DATABASE_URL`.
- **Migrations**: run `npm run db:migrate` when `DATABASE_URL` is set (creates tables). Run `npm run db:generate` after schema changes.
- **File paths**: use `path.join(__dirname, ...)` or `resolveFromRoot()` from `src/lib/paths.js` so paths work in production.

## Rate limiting

- **Auth routes** (`/api/auth/*`): limited to 30 requests per 15 minutes per IP to reduce OTP abuse and brute force. Configure in `src/app.js` (`authLimiter`).

## Billing + AI endpoints

- **Stripe billing**:
  - `POST /api/billing/create-checkout-session` (employer auth required) accepts `{ plan }` where plan is `growth` or `enterprise`, then returns a Stripe Checkout URL.
  - `GET /api/billing/status` (employer auth required) returns `{ plan, status, canPostJobs }`.
  - `POST /api/billing/webhook` handles Stripe subscription lifecycle events.
- **Duplicate-application AI check**:
  - `POST /api/ai/duplicate-application-check` (auth required) accepts `{ jobId, applicationText }`.
  - Uses OpenAI embeddings when `OPENAI_API_KEY` is set; falls back to exact text duplicate checks.

Required env vars for this flow:

```bash
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PRICE_ID_GROWTH=price_...
STRIPE_PRICE_ID_ENTERPRISE=price_...
STRIPE_WEBHOOK_SECRET=whsec_...
APP_BASE_URL=https://skillbridge-bc0e5.web.app
OPENAI_API_KEY=sk-... # optional for semantic matching
OPENAI_EMBEDDING_MODEL=text-embedding-3-small
DUPLICATE_SIMILARITY_THRESHOLD=0.92
```

## Testing

System and unit tests live in `__tests__/`. Run the full suite:

```bash
cd backend
npm install   # once
npm test
```

Tests cover:

- **scoring.service** — normaliseScore, assignTier, identifyGaps, calculateRawScore
- **auth middleware** — protect (401 when no/invalid token, next when valid); requireAdmin (403 non-admin); requireVerified (403 unverified)
- **errorHandler** — asyncHandler (forwards errors to next); globalErrorHandler (500, no message leak in production)
- **env** — validateRequiredEnv (exits when vars missing); getEnv; REQUIRED_ENV
- **otp** — generateOtp (6 digits, crypto); defaultExpiry; OTP_LENGTH
- **paths** — resolveFromRoot (absolute path)

Use `npm run test:watch` for watch mode.

## Docs and checklist

- **[docs/SECURITY_AND_ROBUSTNESS.md](docs/SECURITY_AND_ROBUSTNESS.md)** — Admin protection, row-level security, verification, file paths, recursion/cron guards, memory leaks.
- **[docs/POST_VIBE_CODING_CHECKLIST.md](docs/POST_VIBE_CODING_CHECKLIST.md)** — Run after every AI coding session (secrets grep, auth tests, admin routes, userId ownership, env, npm audit, Prisma, asyncHandler, error handler).

**Find open routes:** `node scripts/check-routes.js` — lists routes and flags those without `authenticate`/`protect` in the chain.
