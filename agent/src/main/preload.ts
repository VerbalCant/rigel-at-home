import { contextBridge, ipcRenderer } from 'electron';

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld(
  'electron',
  {
    ipcRenderer: {
      on(channel: string, func: (...args: any[]) => void) {
        ipcRenderer.on(channel, (_event, ...args) => func(...args));
      },
      invoke(channel: string, ...args: any[]) {
        return ipcRenderer.invoke(channel, ...args);
      },
    },
  }
);