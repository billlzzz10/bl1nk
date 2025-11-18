import { contextBridge } from 'electron';

// Expose a minimal API and feature flags to the renderer
contextBridge.exposeInMainWorld('bl1nk', {
  flags: {
    ENABLE_SHARE_UI: String(process.env.ENABLE_SHARE_UI || '').toLowerCase() === 'true',
    ENABLE_CHAT_UI: String(process.env.ENABLE_CHAT_UI || '').toLowerCase() === 'true',
  }
});

export {};
