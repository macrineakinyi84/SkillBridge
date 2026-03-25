require('dotenv').config();
require('./processHandlers');

const { validateRequiredEnv } = require('./config/env');
const { createApp } = require('./app');

// Only validate what this server needs right now.
validateRequiredEnv(['JWT_SECRET']);

const port = Number(process.env.PORT || 4000);
const app = createApp();

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`SkillBridge API listening on http://localhost:${port}`);
});

