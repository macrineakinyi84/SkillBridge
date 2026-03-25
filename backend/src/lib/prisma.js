/**
 * Single Prisma client instance. Never create new PrismaClient() inside route handlers —
 * that leaks connections and can crash under load (PostgreSQL connection limit).
 *
 * Usage: const prisma = require('../lib/prisma'); then prisma.job.findMany(), etc.
 *
 * On Railway free tier, set connection_limit in DATABASE_URL:
 *   DATABASE_URL="postgresql://user:pass@host/db?connection_limit=5"
 */

let prisma;

try {
  const { PrismaClient } = require('@prisma/client');
  prisma = global.prisma ?? new PrismaClient();
  if (process.env.NODE_ENV !== 'production') {
    global.prisma = prisma;
  }
} catch (e) {
  prisma = null;
  if (process.env.NODE_ENV !== 'test') {
    console.warn('Prisma not available (install @prisma/client when using DB).', e.message);
  }
}

module.exports = prisma;
