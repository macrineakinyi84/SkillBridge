/**
 * Safe file paths: always use path.join(__dirname, ...) so paths resolve correctly
 * in production (e.g. when Node is invoked from a different cwd).
 *
 * ❌ Breaks in production: fs.readFileSync('./templates/cv.html')
 * ✅ Use: resolveFromRoot(relativePath) or path.join(__dirname, '..', 'templates', 'cv.html')
 */

const path = require('path');

/**
 * Resolve a path relative to the backend package root (directory containing src/).
 * Use for templates, static files, and PDF assets.
 *
 * @param {...string} segments - Path segments (e.g. 'templates', 'cv.html')
 * @returns {string} Absolute path
 */
function resolveFromRoot(...segments) {
  const root = path.join(__dirname, '..', '..');
  return path.join(root, ...segments);
}

module.exports = {
  resolveFromRoot,
};
