// Ensure required env for auth tests (getJwtSecret) without triggering validateRequiredEnv
process.env.NODE_ENV = process.env.NODE_ENV || 'test';
if (!process.env.JWT_SECRET) process.env.JWT_SECRET = 'test-secret-for-jest';
