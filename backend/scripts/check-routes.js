#!/usr/bin/env node
/**
 * List every route your Express app registers and flag lines that don't mention
 * "authenticate" or "protect". Run after every AI coding session to find open endpoints.
 *
 * Usage: node scripts/check-routes.js
 * From repo root: node backend/scripts/check-routes.js
 */

const fs = require('fs');
const path = require('path');

const srcDir = path.join(__dirname, '..', 'src');
const routePattern = /router\.(get|post|put|patch|delete)\s*\(\s*['"`]([^'"`]+)/;
const authPattern = /authenticate|protect/;
// Intentional public endpoints (e.g. login/OTP/health checks) can be allowlisted here.
const publicRouteAllowlist = [
  /^\/dev-token\b/,
  /^\/request-otp\b/,
  /^\/verify-otp\b/,
  /^\/login\b/,
  /^\/register\b/,
  /^\/otp\b/,
  /^\/refresh\b/,
  /^\/forgot-password\b/,
  /^\/reset-password\b/,
];

function walk(dir, files = []) {
  if (!fs.existsSync(dir)) return files;
  try {
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, e.name);
      if (e.isDirectory() && e.name !== 'node_modules') walk(full, files);
      else if (e.isFile() && /\.(js|ts)$/.test(e.name)) files.push(full);
    }
  } catch (_) {}
  return files;
}

const files = walk(srcDir);
const lines = [];
for (const file of files) {
  const rel = path.relative(path.join(__dirname, '..'), file);
  let content = '';
  try {
    content = fs.readFileSync(file, 'utf8');
  } catch (_) {}
  content.split('\n').forEach((line, i) => {
    const m = line.match(routePattern);
    if (m) {
      const method = m[1].toUpperCase();
      const route = m[2];
      const isPublic = publicRouteAllowlist.some((re) => re.test(route));
      const hasAuth = authPattern.test(line) || isPublic;
      lines.push({ rel, lineNum: i + 1, method, route, hasAuth, raw: line.trim() });
    }
  });
}

console.log('Routes found in src/:\n');
lines.forEach(({ rel, lineNum, method, route, hasAuth, raw }) => {
  const flag = hasAuth ? '' : ' ⚠️  REVIEW — no authenticate/protect in chain';
  console.log(`${rel}:${lineNum}  ${method.padEnd(6)} ${route}${flag}`);
});
const needReview = lines.filter((l) => !l.hasAuth);
if (needReview.length > 0) {
  console.log('\n' + needReview.length + ' route(s) need review (ensure auth is applied where required).');
  process.exit(1);
}
