# Security and robustness

## 1. Admin endpoints (two-layer middleware)

Every admin route must use **both** `authenticate` and `requireAdmin`:

```js
const { authenticate, requireAdmin } = require('./middleware/auth');

router.delete('/admin/users/:id', authenticate, requireAdmin, deleteUser);
router.get('/admin/analytics', authenticate, requireAdmin, getAnalytics);
```

Find routes that might be missing auth: run `node scripts/check-routes.js` or:

```bash
grep -r "router\.\(get\|post\|put\|patch\|delete\)" src/ --include="*.js"
```

Any line that doesn’t show `authenticate` (or `protect`) needs review.

---

## 2. Email verification and JWT payload

- **JWT payload** must include `isVerified` so verified-only routes can be enforced:

```js
const token = jwt.sign(
  { userId: user.id, role: user.role, isVerified: user.isVerified },
  process.env.JWT_SECRET,
  { expiresIn: '24h' }
);
```

- Use **requireVerified** for routes that should be restricted to verified users:

```js
router.post('/assessments/submit', authenticate, requireVerified, submitAssessment);
router.post('/applications', authenticate, requireVerified, applyToJob);
```

- **OTP**: use `crypto.randomInt()`, never `Math.random()`. Store in DB with expiry (e.g. 10 min). See `src/lib/otp.js`.

---

## 3. Row-level security (never trust client for identity)

- Prefer **server-verified identity** from the JWT:

```js
// ✅ Uses identity from JWT
router.get('/profile/me', authenticate, async (req, res) => {
  const profile = await prisma.studentProfile.findUnique({
    where: { userId: req.user.userId }
  });
  return res.json(profile);
});
```

- If you must use a URL param (e.g. `:userId`), **verify ownership or admin**:

```js
router.get('/profile/:userId', authenticate, async (req, res) => {
  if (req.params.userId !== req.user.userId && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  // ...
});
```

---

## 4. File paths

Use `path.join(__dirname, ...)` so paths resolve correctly in production:

```js
const path = require('path');
const template = fs.readFileSync(
  path.join(__dirname, '..', 'templates', 'cv.html'),
  'utf8'
);
```

Helper: `src/lib/paths.js` — `resolveFromRoot('templates', 'cv.html')`.

---

## 5. Recursion and cron

- **Recursion**: add a max depth guard to avoid infinite loops:

```js
function processSkillTree(node, depth = 0) {
  const MAX_DEPTH = 10;
  if (depth > MAX_DEPTH) throw new Error('Max recursion depth exceeded');
  if (!node.children?.length) return node.score;
  return node.children.map(child => processSkillTree(child, depth + 1));
}
```

- **Cron**: guard against overlapping runs (see `notification.service.js`):

```js
let isRunning = false;
cron.schedule('0 18 * * *', async () => {
  if (isRunning) return;
  isRunning = true;
  try {
    await sendStreakWarnings();
  } finally {
    isRunning = false;
  }
});
```

---

## 6. Memory leaks

- **Event listeners**: remove before re-adding or use `.once()`; avoid adding a new listener on every call without removing.
- **Caches**: use a bounded LRU (e.g. `lru-cache` with `max` and `ttl`), not a growing object.
- **Scripts**: in one-off scripts that use Prisma, call `await prisma.$disconnect()` in a `finally` block.
- **Monitoring**: in production you can log memory every 5 minutes to spot growth:

```js
setInterval(() => {
  const mem = process.memoryUsage();
  console.info({
    heapUsed: `${Math.round(mem.heapUsed / 1024 / 1024)}MB`,
    heapTotal: `${Math.round(mem.heapTotal / 1024 / 1024)}MB`,
  });
}, 5 * 60 * 1000);
```

---

## 7. Async errors and global handler

- Wrap async route handlers with **asyncHandler** so thrown errors go to the error handler:

```js
const { asyncHandler } = require('./middleware/errorHandler');
router.post('/assessments/submit', authenticate, asyncHandler(async (req, res) => {
  const result = await assessmentService.submit(req.body, req.user.userId);
  return res.json({ success: true, data: result });
}));
```

- Register the **global error handler last** in your app:

```js
const { globalErrorHandler } = require('./middleware/errorHandler');
// ... all routes ...
app.use(globalErrorHandler);
```

- In app entry, require **process handlers** first: `require('./src/processHandlers');`

---

## 8. Env and Prisma

- **Env**: validate required vars at startup with `validateRequiredEnv()` from `config/env.js`; server exits with a clear message if any are missing.
- **Prisma**: use the single client from `src/lib/prisma.js`. On Railway free tier, set `?connection_limit=5` in `DATABASE_URL`.

See **POST_VIBE_CODING_CHECKLIST.md** for the full post–AI-session checklist.
