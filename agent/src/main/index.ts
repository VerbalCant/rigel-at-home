import { app, BrowserWindow, ipcMain } from 'electron';
import * as path from 'path';
import { registerTaskHandlers } from './taskHandlers';

let mainWindow: BrowserWindow | null = null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
      preload: path.join(__dirname, 'preload.js'),
    },
  });

  // In development, load from webpack dev server
  if (process.env.NODE_ENV === 'development') {
    const devServerUrl = 'http://localhost:3001';
    console.log('Loading development server URL:', devServerUrl);

    if (mainWindow) {
      mainWindow.loadURL(devServerUrl).catch((err) => {
        console.error('Failed to load dev server:', err);
        // Fallback to loading the local file if dev server fails
        if (mainWindow) {
          mainWindow.loadFile(path.join(__dirname, '../renderer/index.html')).catch(console.error);
        }
      });

      mainWindow.webContents.openDevTools();
    }
  } else {
    // In production, load the bundled file
    if (mainWindow) {
      mainWindow.loadFile(path.join(__dirname, '../renderer/index.html')).catch(console.error);
    }
  }

  mainWindow?.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
    console.error('Failed to load:', { errorCode, errorDescription });
    if (mainWindow) {
      // Retry loading after a short delay
      setTimeout(() => {
        if (mainWindow) {
          console.log('Retrying to load application...');
          if (process.env.NODE_ENV === 'development') {
            mainWindow.loadURL('http://localhost:3001').catch(console.error);
          } else {
            mainWindow.loadFile(path.join(__dirname, '../renderer/index.html')).catch(console.error);
          }
        }
      }, 1000);
    }
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.whenReady().then(() => {
  createWindow();
  registerTaskHandlers(ipcMain);

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});