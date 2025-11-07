declare global {
  interface Window {
    bl1nk?: { flags: { ENABLE_SHARE_UI: boolean; ENABLE_CHAT_UI: boolean } };
  }
}

export {};

