/**
 * Process-level safety net for uncaught exceptions and unhandled rejections.
 * Require this once at the very top of your app entry (e.g. index.js) so one
 * unhandled throw doesn't take down the server silently; Railway will restart the container.
 *
 * Usage in index.js or app.js:
 *   require('./src/processHandlers');
 *   // then require('dotenv').config(); and the rest of the app
 */

function register() {
  process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception — shutting down gracefully:', err);
    process.exit(1);
  });

  process.on('unhandledRejection', (reason) => {
    console.error('Unhandled Promise Rejection:', reason);
    process.exit(1);
  });
}

register();
