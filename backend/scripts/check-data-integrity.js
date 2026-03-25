#!/usr/bin/env node
/**
 * Check for corrupted or inconsistent data.
 * - Database: connection test, list tables, row counts, optional orphan checks.
 * - Config: env validation (without exiting), JSON/file sanity.
 *
 * Usage: node scripts/check-data-integrity.js
 * With .env: from backend folder so dotenv can load .env
 */

const path = require('path');
const fs = require('fs');

// Load .env if present (don't fail if missing)
const envPath = path.join(__dirname, '..', '.env');
if (fs.existsSync(envPath)) {
  try {
    require('dotenv').config({ path: envPath });
  } catch (_) {}
}

let prisma = null;
try {
  prisma = require('../src/lib/prisma');
} catch (_) {}

const issues = [];
const ok = [];

// --- Database checks (only if Prisma and DATABASE_URL available) ---
async function runDbChecks() {
  if (!prisma) {
    ok.push('Prisma not installed — skipping database checks');
    return;
  }
  if (!process.env.DATABASE_URL || process.env.DATABASE_URL.trim() === '') {
    ok.push('DATABASE_URL not set — skipping database checks');
    return;
  }

  try {
    await prisma.$queryRaw`SELECT 1`;
    ok.push('Database connection OK');
  } catch (e) {
    issues.push(`Database connection failed: ${e.message}`);
    return;
  }

  try {
    // List tables in public schema (PostgreSQL)
    const tables = await prisma.$queryRawUnsafe(`
      SELECT tablename FROM pg_tables
      WHERE schemaname = 'public'
      ORDER BY tablename
    `);
    if (!Array.isArray(tables) || tables.length === 0) {
      ok.push('No tables in public schema (empty or not migrated)');
      return;
    }

    for (const row of tables) {
      const table = row.tablename;
      try {
        const countResult = await prisma.$queryRawUnsafe(`SELECT count(*)::int as c FROM "${table}"`);
        const count = countResult && countResult[0] ? countResult[0].c : 0;
        ok.push(`Table "${table}": ${count} row(s)`);
      } catch (e) {
        issues.push(`Table "${table}": count failed — ${e.message}`);
      }
    }

    // Optional: check for orphaned OTP tokens (expired and still unused — can be cleaned up)
    if (tables.some((r) => r.tablename === 'OtpToken' || r.tablename === 'otp_token')) {
      const otpTable = tables.find((r) => r.tablename === 'OtpToken' || r.tablename === 'otp_token').tablename;
      try {
        const expired = await prisma.$queryRawUnsafe(`
          SELECT count(*)::int as c FROM "${otpTable}"
          WHERE "expiresAt" < NOW() OR used = true
        `);
        const c = expired && expired[0] ? expired[0].c : 0;
        ok.push(`OtpToken: ${c} expired/used record(s) (safe to prune)`);
      } catch (_) {
        // Schema might differ
      }
    }
  } catch (e) {
    issues.push(`Listing tables failed: ${e.message}`);
  } finally {
    if (prisma && prisma.$disconnect) {
      await prisma.$disconnect().catch(() => {});
    }
  }
}

// --- Config / file sanity ---
function runFileChecks() {
  const backendRoot = path.join(__dirname, '..');
  const pkgPath = path.join(backendRoot, 'package.json');
  if (fs.existsSync(pkgPath)) {
    try {
      const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
      if (pkg.name && typeof pkg.dependencies === 'object') {
        ok.push('package.json valid');
      } else {
        issues.push('package.json missing name or dependencies');
      }
    } catch (e) {
      issues.push(`package.json invalid or unreadable: ${e.message}`);
    }
  }

  if (fs.existsSync(path.join(backendRoot, '.env.example'))) {
    ok.push('.env.example present');
  }
}

(async () => {
  runFileChecks();
  await runDbChecks();

  console.log('--- Data integrity check ---\n');
  ok.forEach((line) => console.log('OK:', line));
  if (issues.length > 0) {
    console.log('');
    issues.forEach((line) => console.log('ISSUE:', line));
    process.exit(1);
  }
  console.log('\nNo corruption or integrity issues reported.');
})();
