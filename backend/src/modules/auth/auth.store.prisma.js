const crypto = require('crypto');
const prisma = require('../../lib/prisma');

function normaliseEmail(email) {
  return String(email || '').trim().toLowerCase();
}

function sha256(input) {
  return crypto.createHash('sha256').update(input).digest('hex');
}

const ALLOWED_ROLES = ['student', 'employer', 'admin'];

async function getOrCreateUserByEmail(email, roleOptional) {
  if (!prisma) return null;
  const key = normaliseEmail(email);
  if (!key) return null;

  let user = await prisma.user.findUnique({ where: { email: key } });
  if (user) {
    return {
      id: user.id,
      email: user.email,
      role: user.role,
      isVerified: user.isVerified,
      createdAt: user.createdAt,
    };
  }

  const role = ALLOWED_ROLES.includes(roleOptional) ? roleOptional : 'student';
  user = await prisma.user.create({
    data: {
      email: key,
      role,
      isVerified: false,
    },
  });
  return {
    id: user.id,
    email: user.email,
    role: user.role,
    isVerified: user.isVerified,
    createdAt: user.createdAt,
  };
}

async function setOtpForEmail(email, otp, expiresAt) {
  if (!prisma) return;
  const key = normaliseEmail(email);
  await prisma.otpToken.create({
    data: {
      email: key,
      otpHash: sha256(`${key}:${otp}`),
      expiresAt,
      used: false,
    },
  });
  // Keep only latest OTP per email (optional: delete older)
  const tokens = await prisma.otpToken.findMany({
    where: { email: key },
    orderBy: { createdAt: 'desc' },
    skip: 1,
  });
  if (tokens.length > 0) {
    await prisma.otpToken.deleteMany({
      where: { id: { in: tokens.map((t) => t.id) } },
    });
  }
}

async function verifyOtpForEmail(email, otp) {
  if (!prisma) return { ok: false, reason: 'missing' };
  const key = normaliseEmail(email);
  const record = await prisma.otpToken.findFirst({
    where: { email: key, used: false },
    orderBy: { createdAt: 'desc' },
  });
  if (!record) return { ok: false, reason: 'missing' };
  if (record.expiresAt.getTime() < Date.now()) return { ok: false, reason: 'expired' };
  const candidateHash = sha256(`${key}:${otp}`);
  if (candidateHash !== record.otpHash) return { ok: false, reason: 'invalid' };
  await prisma.otpToken.update({ where: { id: record.id }, data: { used: true } });
  return { ok: true };
}

async function markVerified(email) {
  if (!prisma) return null;
  const key = normaliseEmail(email);
  const user = await prisma.user.update({
    where: { email: key },
    data: { isVerified: true },
  });
  return {
    id: user.id,
    email: user.email,
    role: user.role,
    isVerified: user.isVerified,
    createdAt: user.createdAt,
  };
}

module.exports = {
  normaliseEmail,
  getOrCreateUserByEmail,
  setOtpForEmail,
  verifyOtpForEmail,
  markVerified,
};
