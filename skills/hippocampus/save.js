/**
 * Save current memory state to .hippocampus.json
 *
 * This skill saves the current project context, tasks, and file tracking.
 * Automatically preserves existing data and updates timestamps.
 *
 * @param {string} [customJson] Optional custom JSON to save instead of current state
 * @returns {string} Success message or error message
 */
export async function use(customJson = '') {
  const { exec } = require('child_process');
  const util = require('util');
  const fs = require('fs').promises;
  const os = require('os');
  const path = require('path');
  const execPromise = util.promisify(exec);

  try {
    // Use python3 for macOS/Linux, python for Windows
    const pythonCmd = process.platform === 'win32' ? 'python' : 'python3';

    // If custom JSON provided, use it directly
    if (customJson) {
      // Create a temporary file to pass JSON safely
      const tempDir = os.tmpdir();
      const tempFile = path.join(tempDir, `hippocampus_save_${Date.now()}.json`);

      await fs.writeFile(tempFile, customJson, 'utf-8');

      try {
        // Pass file path instead of inline JSON to avoid shell injection
        const result = await execPromise(`${pythonCmd} tools/hippocampus.py save @${tempFile}`, {
          cwd: process.env.CLAUDE_WORKING_DIRECTORY || process.cwd(),
          timeout: 5000
        });

        if (result.stderr) {
          console.error('[Hippocampus] Error:', result.stderr);
        }
        console.log('[Hippocampus] Memory saved with custom data');
      } finally {
        // Clean up temp file
        await fs.unlink(tempFile).catch(() => {});
      }

      return 'Memory saved successfully';
    }

    // Otherwise, read current memory and update timestamp
    const memoryFile = process.env.CLAUDE_WORKING_DIRECTORY
      ? `${process.env.CLAUDE_WORKING_DIRECTORY}/.hippocampus.json`
      : './.hippocampus.json';

    let currentData = {
      project_context: '',
      active_tasks: [],
      technical_debt: [],
      file_map: {}
    };

    // Try to read existing memory
    try {
      await fs.stat(memoryFile);
      const content = await fs.readFile(memoryFile, 'utf-8');
      currentData = JSON.parse(content);
    } catch (e) {
      // File doesn't exist yet, use empty state
      console.log('[Hippocampus] No existing memory, creating new');
    }

    // Update timestamp
    const saveData = {
      ...currentData,
      last_updated: new Date().toISOString()
    };

    const jsonData = JSON.stringify(saveData);

    // Create temp file for JSON
    const tempDir = os.tmpdir();
    const tempFile = path.join(tempDir, `hippocampus_save_${Date.now()}.json`);

    await fs.writeFile(tempFile, jsonData, 'utf-8');

    try {
      const result = await execPromise(`${pythonCmd} tools/hippocampus.py save @${tempFile}`, {
        cwd: process.env.CLAUDE_WORKING_DIRECTORY || process.cwd(),
        timeout: 5000
      });

      if (result.stderr) {
        console.error('[Hippocampus] Error:', result.stderr);
      }

      console.log('[Hippocampus] Memory saved');
    } finally {
      // Clean up temp file
      await fs.unlink(tempFile).catch(() => {});
    }

    return 'Memory saved successfully';
  } catch (error) {
    console.error('[Hippocampus] Failed to save memory:', error.message);
    return 'Failed to save memory';
  }
}
