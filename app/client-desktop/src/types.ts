// Type definitions for bl1nk Desktop

export interface ChatThread {
  id: string;
  workspaceId: string;
  title: string | null;
  modelConfig: ModelConfig;
  createdAt: number;
  updatedAt: number;
}

export interface ChatMessage {
  id: string;
  threadId: string;
  workspaceId: string;
  role: 'user' | 'assistant';
  text: string;
  status: 'pending' | 'streaming' | 'completed' | 'error';
  meta?: Record<string, any>;
  parentId?: string | null;
  createdAt: number;
}

export interface ModelConfig {
  provider: 'openai' | 'google' | 'mistral' | 'anthropic';
  modelId: string;
  params?: {
    temperature?: number;
    maxTokens?: number;
    topP?: number;
  };
}

export interface Workspace {
  id: string;
  name: string;
  ownerAccountId: string | null;
  createdAt: number;
  updatedAt: number;
}

export interface MessageStreamEvent {
  type: 'status' | 'delta' | 'done';
  status?: 'pending' | 'streaming' | 'completed' | 'error';
  text?: string;
  done?: boolean;
  error?: string;
}

export interface ContextFile {
  id: string;
  workspaceId: string;
  name: string;
  sourceType: 'upload' | 'web';
  loaderType: 'pdf' | 'txt' | 'markdown' | 'unknown';
  path?: string;
  url?: string;
  hash?: string;
  status: 'uploading' | 'pending_chunks' | 'ready' | 'error';
  createdAt: number;
}

export interface ApiConfig {
  baseUrl: string;
  authToken?: string;
}

export interface FeatureFlags {
  ENABLE_SHARE_UI: boolean;
  ENABLE_CHAT_UI: boolean;
}
