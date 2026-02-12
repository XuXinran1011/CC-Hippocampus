/**
 * Load external memory from .hippocampus.json
 *
 * This skill is automatically triggered on session start via hook.
 * Can also be called manually when needed.
 *
 * @returns {string} Formatted memory content or empty string
 */
export async function use() {
  const { exec } = require('child_process');
  const util = require('util');
  const execPromise = util.promisify(exec);

  try {
    // Use python3 for macOS/Linux, python for Windows
    const pythonCmd = process.platform === 'win32' ? 'python' : 'python3';
    const result = await execPromise(`${pythonCmd} tools/hippocampus.py load`, {
      cwd: process.env.CLAUDE_WORKING_DIRECTORY || process.cwd(),
      timeout: 5000
    });

    if (result.stdout) {
      console.log('[Hippocampus] Memory loaded');
    }
    if (result.stderr) {
      console.error('[Hippocampus] Error:', result.stderr);
    }

    return result.stdout || '';
  } catch (error) {
    console.error('[Hippocampus] Failed to load memory:', error.message);
    return '';
  }
}
