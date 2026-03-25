const { validateRequiredEnv, getEnv, REQUIRED_ENV } = require('../src/config/env');

describe('env', () => {
  const exitSpy = jest.spyOn(process, 'exit').mockImplementation((code) => {
    throw new Error(`process.exit(${code})`);
  });
  const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});

  afterAll(() => {
    exitSpy.mockRestore();
    consoleSpy.mockRestore();
  });

  describe('validateRequiredEnv', () => {
    it('exits with 1 when a required var is missing', () => {
      const required = ['MUST_BE_MISSING_VAR'];
      expect(() => validateRequiredEnv(required)).toThrow('process.exit(1)');
      expect(process.exit).toHaveBeenCalledWith(1);
    });

    it('does not exit when all required vars are set', () => {
      const required = ['JWT_SECRET'];
      const prev = process.env.JWT_SECRET;
      process.env.JWT_SECRET = 'set';
      exitSpy.mockClear();
      validateRequiredEnv(required);
      process.env.JWT_SECRET = prev;
      expect(exitSpy).not.toHaveBeenCalled();
    });

    it('exits when var is empty string', () => {
      const required = ['EMPTY_VAR'];
      process.env.EMPTY_VAR = '';
      expect(() => validateRequiredEnv(required)).toThrow('process.exit(1)');
      delete process.env.EMPTY_VAR;
    });
  });

  describe('getEnv', () => {
    it('returns default when var is missing', () => {
      expect(getEnv('NONEXISTENT_VAR_XYZ', 'default')).toBe('default');
    });

    it('returns value when var is set', () => {
      process.env.TEST_ENV_VAR = 'hello';
      expect(getEnv('TEST_ENV_VAR')).toBe('hello');
      delete process.env.TEST_ENV_VAR;
    });
  });

  describe('REQUIRED_ENV', () => {
    it('includes DATABASE_URL and JWT_SECRET', () => {
      expect(REQUIRED_ENV).toContain('DATABASE_URL');
      expect(REQUIRED_ENV).toContain('JWT_SECRET');
    });
  });
});
