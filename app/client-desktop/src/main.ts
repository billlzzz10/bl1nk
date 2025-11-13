import { app, BrowserWindow, ipcMain } from 'electron';
import { fileURLToPath } from 'url';
import { join, dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

let mainWindow: BrowserWindow | null = null;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      preload: join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
    backgroundColor: '#0f172a',
    show: false,
  });

  mainWindow.loadFile(join(__dirname, 'renderer', 'index.html'));

  // Show window when ready
  mainWindow.once('ready-to-show', () => {
    mainWindow?.show();
  });

  // Open DevTools in development
  if (process.env.NODE_ENV === 'development') {
    mainWindow.webContents.openDevTools();
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// IPC Handlers
ipcMain.handle('get-config', () => {
  return {
    apiBaseUrl: process.env.API_BASE_URL || 'http://localhost:3333',
    redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
    qdrantUrl: process.env.QDRANT_URL || 'http://localhost:6333',
  };
});

ipcMain.handle('get-feature-flags', () => {
  return {
    ENABLE_SHARE_UI: String(process.env.ENABLE_SHARE_UI || '').toLowerCase() === 'true',
    ENABLE_CHAT_UI: String(process.env.ENABLE_CHAT_UI || '').toLowerCase() === 'true',
  };
});

ipcMain.handle('store-auth-token', async (_event, token: string) => {
  // In production, use electron-store or keytar for secure storage
  // For now, we'll just acknowledge the storage
  console.log('Auth token stored');
  return true;
});

ipcMain.handle('get-auth-token', async () => {
  // In production, retrieve from secure storage
  return null;
});

ipcMain.handle('clear-auth-token', async () => {
  console.log('Auth token cleared');
  return true;
});

// App lifecycle
app.whenReady().then(() => {
  createWindow();

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

// Handle app errors
process.on('uncaughtException', (error) => {
  console.error('Uncaught exception:', error);
});

process.on('unhandledRejection', (error) => {
  console.error('Unhandled rejection:', error);
});

