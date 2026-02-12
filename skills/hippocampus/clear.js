/**
 * Clear and archive current memory
 *
 * This skill archives the current memory state to .hippocampus_history/
 * and resets to an empty state. Useful for creating recovery points
 * or starting fresh.
 *
 * @returns {string} Success message or error message
 */
export async function use() {
  const { exec } = require('child_process');
  const util = require('util');
  const execPromise = util.promisify(exec);

  try {
    // Use python3 for macOS/Linux, python for Windows
    const pythonCmd = process.platform === 'win32' ? 'python' : 'python3';
    const result = await execPromise(`${pythonCmd} tools/hippocampus.py clear`, {
      cwd: process.env.CLAUDE_WORKING_DIRECTORY || process.cwd(),
      timeout: 5000
    });

    if (result.stdout) {
      console.log('[Hippocampus] Memory cleared and archived');
    }
    if (result.stderr) {
      console.error('[Hippocampus] Error:', result.stderr);
    }

    return 'Memory cleared and archived';
  } catch (error) {
    console.error('[Hippocampus] Failed to clear memory:', error.message);
    return 'Failed to clear memory';
  }
}
