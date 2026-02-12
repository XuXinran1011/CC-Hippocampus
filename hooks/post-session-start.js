/**
 * Auto-load memory on session start
 *
 * This hook is automatically triggered when a new Claude Code session starts.
 * It loads the external memory from .hippocampus.json and injects it into
 * the session context.
 *
 * Location: ~/.claude/hooks/post-session-start.js
 */
module.exports = async function({ session }) {
  const { exec } = require('child_process');
  const util = require('util');
  const execPromise = util.promisify(exec);

  try {
    // Use python3 for macOS/Linux, python for Windows
    const pythonCmd = process.platform === 'win32' ? 'python' : 'python3';

    // Load memory silently
    await execPromise(`${pythonCmd} tools/hippocampus.py load`, {
      cwd: process.env.CLAUDE_WORKING_DIRECTORY || process.cwd(),
      timeout: 5000
    });

    console.log('[Hippocampus] ✓ Memory auto-loaded on session start');
  } catch (error) {
    // Silent fail - memory might not exist yet or user hasn't installed plugin
    // Don't clutter console with errors for first-time users
  }

  return session;
};
