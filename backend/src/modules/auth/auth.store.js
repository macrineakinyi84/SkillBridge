const crypto = require('crypto');
const prisma = require('../../lib/prisma');
const { getDatabaseUrl } = require('../../config/env');

const usePrisma = prisma && getDatabaseUrl() && getDatabaseUrl().trim().length > 0;
const prismaStore = usePrisma ? require('./auth.store.prisma') : null;

// In-memory fallback (e.g. tests or no DATABASE_URL)
const usersByEmail = new Map();
const otpByEmail = new Map();

function normaliseEmail(email) {
  return String(email || '').trim().toLowerCase();
}

function sha256(input) {
  return crypto.createHash('sha256').update(input).digest('hex');
}

const ALLOWED_ROLES = ['student', 'employer', 'admin'];

async function getOrCreateUserByEmail(email, roleOptional) {
  if (prismaStore) return prismaStore.getOrCreateUserByEmail(email, roleOptional);
  const key = normaliseEmail(email);
  if (!key) return null;
  const existing = usersByEmail.get(key);
  if (existing) return existing;
  const role = ALLOWED_ROLES.includes(roleOptional) ? roleOptional : 'student';
  const user = {
    id: crypto.randomUUID(),
    email: key,
    role,
    isVerified: false,
    createdAt: new Date(),
  };
  usersByEmail.set(key, user);
  return user;
}

async function setOtpForEmail(email, otp, expiresAt) {
  if (prismaStore) return prismaStore.setOtpForEmail(email, otp, expiresAt);
  const key = normaliseEmail(email);
  otpByEmail.set(key, { otpHash: sha256(`${key}:${otp}`), expiresAt });
}

async function verifyOtpForEmail(email, otp) {
  if (prismaStore) return prismaStore.verifyOtpForEmail(email, otp);
  const key = normaliseEmail(email);
  const record = otpByEmail.get(key);
  if (!record) return { ok: false, reason: 'missing' };
  if (record.expiresAt.getTime() < Date.now()) return { ok: false, reason: 'expired' };
  const candidateHash = sha256(`${key}:${otp}`);
  if (candidateHash !== record.otpHash) return { ok: false, reason: 'invalid' };
  otpByEmail.delete(key);
  return { ok: true };
}

async function markVerified(email) {
  if (prismaStore) return prismaStore.markVerified(email);
  const key = normaliseEmail(email);
  const user = usersByEmail.get(key);
  if (!user) return null;
  user.isVerified = true;
  return user;
}

module.exports = {
  normaliseEmail,
  getOrCreateUserByEmail,
  setOtpForEmail,
  verifyOtpForEmail,
  markVerified,
};
