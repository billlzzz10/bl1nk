import { contextBridge, ipcRenderer } from 'electron';

// Expose secure API to renderer process
contextBridge.exposeInMainWorld('bl1nk', {
  // Feature flags
  flags: {
    ENABLE_SHARE_UI: String(process.env.ENABLE_SHARE_UI || '').toLowerCase() === 'true',
    ENABLE_CHAT_UI: String(process.env.ENABLE_CHAT_UI || '').toLowerCase() === 'true',
  },
  
  // Configuration
  getConfig: () => ipcRenderer.invoke('get-config'),
  getFeatureFlags: () => ipcRenderer.invoke('get-feature-flags'),
  
  // Auth
  storeAuthToken: (token: string) => ipcRenderer.invoke('store-auth-token', token),
  getAuthToken: () => ipcRenderer.invoke('get-auth-token'),
  clearAuthToken: () => ipcRenderer.invoke('clear-auth-token'),
});

export {};
