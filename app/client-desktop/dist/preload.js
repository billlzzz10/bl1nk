import { contextBridge } from 'electron';
import { parseBooleanFlag } from './utils/flags.js';
/**
 * Expose a minimal API and feature flags to the renderer.
 * Flags are driven by environment variables set at app start.
 */
contextBridge.exposeInMainWorld('bl1nk', {
    flags: {
        ENABLE_SHARE_UI: parseBooleanFlag(process.env.ENABLE_SHARE_UI),
        ENABLE_CHAT_UI: parseBooleanFlag(process.env.ENABLE_CHAT_UI),
    }
});
