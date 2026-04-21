const express = require('express');
const crypto = require('crypto');

const prisma = require('../lib/prisma');
const { authenticate } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');
const { getEnv } = require('../config/env');

const router = express.Router();

function normalizeText(text) {
  return String(text || '')
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function hashText(text) {
  return crypto.createHash('sha256').update(text).digest('hex');
}

function cosineSimilarity(a, b) {
  if (!Array.isArray(a) || !Array.isArray(b) || a.length !== b.length || a.length === 0) return 0;
  let dot = 0;
  let normA = 0;
  let normB = 0;
  for (let i = 0; i < a.length; i += 1) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  if (normA === 0 || normB === 0) return 0;
  return dot / (Math.sqrt(normA) * Math.sqrt(normB));
}

async function fetchEmbedding(input) {
  const key = getEnv('OPENAI_API_KEY');
  if (!key) return null;
  const response = await fetch('https://api.openai.com/v1/embeddings', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${key}`,
    },
    body: JSON.stringify({
      model: getEnv('OPENAI_EMBEDDING_MODEL', 'text-embedding-3-small'),
      input,
    }),
  });
  if (!response.ok) {
    throw new Error(`Embedding request failed with ${response.status}`);
  }
  const json = await response.json();
  return json?.data?.[0]?.embedding ?? null;
}

router.post('/duplicate-application-check', authenticate, asyncHandler(async (req, res) => {
  const userId = req.user.userId;
  const { jobId, applicationText } = req.body || {};
  if (!jobId || !applicationText) {
    return res.status(400).json({ success: false, error: { message: 'jobId and applicationText are required' } });
  }

  const normalized = normalizeText(applicationText);
  const textHash = hashText(normalized);

  const previous = await prisma?.applicationIntent.findMany({
    where: { userId, jobExternalId: String(jobId) },
    orderBy: { createdAt: 'desc' },
    take: 10,
  });

  const exact = previous?.find((x) => hashText(normalizeText(x.content)) === textHash);
  if (exact) {
    return res.json({
      success: true,
      data: { isDuplicate: true, reason: 'exact_text_match', similarity: 1.0 },
    });
  }

  let similarity = 0;
  const embedding = await fetchEmbedding(normalized).catch(() => null);
  if (embedding && previous?.length) {
    for (const item of previous) {
      const prevEmbedding = Array.isArray(item.embedding) ? item.embedding : null;
      if (!prevEmbedding) continue;
      similarity = Math.max(similarity, cosineSimilarity(embedding, prevEmbedding));
    }
  }

  const threshold = Number(getEnv('DUPLICATE_SIMILARITY_THRESHOLD', '0.92'));
  const isDuplicate = similarity >= threshold;

  await prisma?.applicationIntent.create({
    data: {
      userId,
      jobExternalId: String(jobId),
      content: applicationText,
      embedding: embedding ?? undefined,
    },
  });

  return res.json({
    success: true,
    data: {
      isDuplicate,
      reason: isDuplicate ? 'semantic_similarity' : 'ok',
      similarity,
      threshold,
    },
  });
}));

module.exports = router;

