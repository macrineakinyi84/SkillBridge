const path = require('path');
const { resolveFromRoot } = require('../src/lib/paths');

describe('paths', () => {
  describe('resolveFromRoot', () => {
    it('returns absolute path under backend root', () => {
      const result = resolveFromRoot('templates', 'cv.html');
      expect(path.isAbsolute(result)).toBe(true);
      expect(result).toContain('templates');
      expect(result).toContain('cv.html');
    });

    it('resolves single segment', () => {
      const result = resolveFromRoot('templates');
      expect(result).toContain('templates');
    });
  });
});
