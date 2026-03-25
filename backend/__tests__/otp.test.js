const { generateOtp, defaultExpiry, OTP_LENGTH } = require('../src/lib/otp');

describe('otp', () => {
  describe('generateOtp', () => {
    it('returns a string of 6 digits', () => {
      const otp = generateOtp();
      expect(otp).toMatch(/^\d{6}$/);
    });

    it('returns different values on multiple calls', () => {
      const set = new Set();
      for (let i = 0; i < 20; i++) set.add(generateOtp());
      expect(set.size).toBeGreaterThan(1);
    });
  });

  describe('defaultExpiry', () => {
    it('returns a Date in the future', () => {
      const before = Date.now();
      const expiry = defaultExpiry();
      const after = Date.now();
      expect(expiry.getTime()).toBeGreaterThanOrEqual(before + 9 * 60 * 1000);
      expect(expiry.getTime()).toBeLessThanOrEqual(after + 11 * 60 * 1000);
    });
  });

  describe('OTP_LENGTH', () => {
    it('is 6', () => {
      expect(OTP_LENGTH).toBe(6);
    });
  });
});
