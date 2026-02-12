/**
 * Get memory statistics
 *
 * This skill returns detailed information about the current memory state,
 * including file size, last update time, and counts of various items.
 *
 * @returns {string} JSON-formatted statistics or error message
 */
export async function use() {
  const { exec } = require('child_process');
  const util = require('util');
  const execPromise = util.promisify(exec);

  try {
    // Use python3 for macOS/Linux, python for Windows
    const pythonCmd = process.platform === 'win32' ? 'python' : 'python3';
    const result = await execPromise(`${pythonCmd} tools/hippocampus.py stats`, {
      cwd: process.env.CLAUDE_WORKING_DIRECTORY || process.cwd(),
      timeout: 5000
    });

    if (result.stdout) {
      console.log('[Hippocampus] Stats retrieved');
      return result.stdout;
    }
    if (result.stderr) {
      console.error('[Hippocampus] Error:', result.stderr);
    }

    return result.stdout || '';
  } catch (error) {
    console.error('[Hippocampus] Failed to get stats:', error.message);
    return 'Failed to get stats';
  }
}
