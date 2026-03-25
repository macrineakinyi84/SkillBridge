# Post–vibe-coding checklist

Run through this **after every AI coding session** before committing.

## Security

- [ ] **Secrets**: `grep -r "api_key\|secret\|password" src/ --include="*.js" --include="*.ts"` — ensure no hardcoded values.
- [ ] **Auth (no token)**: Test all protected routes with no `Authorization` header → expect **401**.
- [ ] **Auth (wrong role)**: Test admin routes with a non-admin JWT → expect **403**.
- [ ] **Admin routes**: `curl` every `/admin/*` route without auth → expect **401**.
- [ ] **Row-level security**: For every route that takes a `:userId` (or similar) param, confirm it either:
  - uses `req.user.userId` from the JWT only (e.g. `GET /profile/me`), or
  - checks ownership: `req.params.userId === req.user.userId || req.user.role === 'admin'`.

## Config and infra

- [ ] **Env vars**: All required vars are set in Railway (or your host) dashboard — none hardcoded.
- [ ] **npm audit**: Run `npm audit` and fix any **high** or **critical** vulnerabilities.

## Code quality

- [ ] **Prisma**: No `new PrismaClient()` inside route handlers or per-request code — use the singleton from `src/lib/prisma.js`.
- [ ] **Async routes**: Every async route handler is wrapped in `asyncHandler(...)`.
- [ ] **Error handler**: The global Express error handler is still the **last** middleware registered in `app.js` (or your main app file).

## Find open routes (run after every AI session)

List every route and ensure admin/protected routes include `authenticate` (and admin routes include `requireAdmin`):

```bash
# From backend folder (Git Bash or WSL)
grep -r "router\.\(get\|post\|put\|patch\|delete\)" src/ --include="*.js"
```

Or use the script:

```bash
node scripts/check-routes.js
```

Any route that doesn’t show `authenticate` (or `protect`) in the same chain needs to be reviewed immediately.
