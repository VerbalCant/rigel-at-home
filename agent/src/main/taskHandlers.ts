import { IpcMain } from 'electron';
import { spawn } from 'child_process';
import * as path from 'path';
import * as fs from 'fs';

interface TaskProgress {
  percent: number;
  status: string;
  message?: string;
}

export function registerTaskHandlers(ipcMain: IpcMain) {
  ipcMain.handle('execute-task', async (event, task: any) => {
    const { code, id } = task;
    const tempDir = path.join(__dirname, '../../temp');

    // Ensure temp directory exists
    if (!fs.existsSync(tempDir)) {
      fs.mkdirSync(tempDir, { recursive: true });
    }

    const scriptPath = path.join(tempDir, `task_${id}.py`);
    fs.writeFileSync(scriptPath, code);

    return new Promise((resolve, reject) => {
      const process = spawn('python3', [scriptPath]);
      let output = '';
      let error = '';

      process.stdout.on('data', (data) => {
        output += data.toString();
        const progress: TaskProgress = {
          percent: 50, // This is a placeholder, actual progress would need to be calculated
          status: 'running',
          message: data.toString(),
        };
        event.sender.send('task-progress', progress);
      });

      process.stderr.on('data', (data) => {
        error += data.toString();
      });

      process.on('close', (code) => {
        // Clean up temp file
        fs.unlinkSync(scriptPath);

        if (code === 0) {
          resolve({ output, executionTime: 0 }); // Add actual execution time calculation
        } else {
          reject(new Error(error || 'Task execution failed'));
        }
      });
    });
  });

  ipcMain.handle('get-system-info', async () => {
    const os = require('os');
    return {
      memory: os.totalmem(),
      cpuCores: os.cpus().length,
      features: ['python3'], // Add feature detection logic
    };
  });
}