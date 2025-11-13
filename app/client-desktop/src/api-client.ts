// API Client for bl1nk Desktop
import type { 
  ChatThread, 
  ChatMessage, 
  Workspace, 
  MessageStreamEvent,
  ModelConfig,
  ApiConfig 
} from './types.js';

export class ApiClient {
  private baseUrl: string;
  private authToken?: string;

  constructor(config: ApiConfig) {
    this.baseUrl = config.baseUrl;
    this.authToken = config.authToken;
  }

  setAuthToken(token: string) {
    this.authToken = token;
  }

  private getHeaders(): HeadersInit {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
    };
    if (this.authToken) {
      headers['Authorization'] = `Bearer ${this.authToken}`;
    }
    return headers;
  }

  // Workspaces
  async getWorkspaces(): Promise<Workspace[]> {
    const response = await fetch(`${this.baseUrl}/workspaces`, {
      headers: this.getHeaders(),
    });
    if (!response.ok) throw new Error(`Failed to fetch workspaces: ${response.statusText}`);
    return response.json();
  }

  async getWorkspace(id: string): Promise<Workspace> {
    const response = await fetch(`${this.baseUrl}/workspaces/${id}`, {
      headers: this.getHeaders(),
    });
    if (!response.ok) throw new Error(`Failed to fetch workspace: ${response.statusText}`);
    return response.json();
  }

  async createWorkspace(name: string): Promise<Workspace> {
    const response = await fetch(`${this.baseUrl}/workspaces`, {
      method: 'POST',
      headers: this.getHeaders(),
      body: JSON.stringify({ name }),
    });
    if (!response.ok) throw new Error(`Failed to create workspace: ${response.statusText}`);
    return response.json();
  }

  // Threads
  async getThreads(workspaceId: string, limit = 50, offset = 0): Promise<ChatThread[]> {
    const params = new URLSearchParams({
      workspaceId,
      limit: limit.toString(),
      offset: offset.toString(),
    });
    const response = await fetch(`${this.baseUrl}/threads?${params}`, {
      headers: this.getHeaders(),
    });
    if (!response.ok) throw new Error(`Failed to fetch threads: ${response.statusText}`);
    return response.json();
  }

  async getThread(id: string): Promise<ChatThread> {
    const response = await fetch(`${this.baseUrl}/threads/${id}`, {
      headers: this.getHeaders(),
    });
    if (!response.ok) throw new Error(`Failed to fetch thread: ${response.statusText}`);
    return response.json();
  }

  async createThread(
    workspaceId: string,
    title?: string,
    modelConfig?: ModelConfig
  ): Promise<ChatThread> {
    const response = await fetch(`${this.baseUrl}/threads`, {
      method: 'POST',
      headers: this.getHeaders(),
      body: JSON.stringify({ workspaceId, title, modelConfig }),
    });
    if (!response.ok) throw new Error(`Failed to create thread: ${response.statusText}`);
    return response.json();
  }

  async updateThread(
    id: string,
    updates: { title?: string; modelConfig?: ModelConfig }
  ): Promise<ChatThread> {
    const response = await fetch(`${this.baseUrl}/threads/${id}`, {
      method: 'PATCH',
      headers: this.getHeaders(),
      body: JSON.stringify(updates),
    });
    if (!response.ok) throw new Error(`Failed to update thread: ${response.statusText}`);
    return response.json();
  }

  async deleteThread(id: string): Promise<void> {
    const response = await fetch(`${this.baseUrl}/threads/${id}`, {
      method: 'DELETE',
      headers: this.getHeaders(),
    });
    if (!response.ok) throw new Error(`Failed to delete thread: ${response.statusText}`);
  }

  // Messages
  async getMessages(threadId: string, limit = 100, offset = 0): Promise<ChatMessage[]> {
    const params = new URLSearchParams({
      threadId,
      limit: limit.toString(),
      offset: offset.toString(),
    });
    const response = await fetch(`${this.baseUrl}/messages?${params}`, {
      headers: this.getHeaders(),
    });
    if (!response.ok) throw new Error(`Failed to fetch messages: ${response.statusText}`);
    return response.json();
  }

  async sendMessage(
    threadId: string,
    workspaceId: string,
    text: string,
    parentId?: string,
    meta?: Record<string, any>
  ): Promise<{ messageId: string }> {
    const response = await fetch(`${this.baseUrl}/messages`, {
      method: 'POST',
      headers: this.getHeaders(),
      body: JSON.stringify({ threadId, workspaceId, text, parentId, meta }),
    });
    if (!response.ok) throw new Error(`Failed to send message: ${response.statusText}`);
    return response.json();
  }

  // SSE Streaming
  async *streamMessage(messageId: string): AsyncGenerator<MessageStreamEvent> {
    const response = await fetch(`${this.baseUrl}/messages/stream/${messageId}`, {
      headers: this.getHeaders(),
    });

    if (!response.ok) {
      throw new Error(`Failed to stream message: ${response.statusText}`);
    }

    const reader = response.body?.getReader();
    if (!reader) throw new Error('No response body');

    const decoder = new TextDecoder();
    let buffer = '';

    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() || '';

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const data = line.substring(6);
            try {
              const event = JSON.parse(data) as MessageStreamEvent;
              yield event;
            } catch (e) {
              console.error('Failed to parse SSE event:', e);
            }
          }
        }
      }
    } finally {
      reader.releaseLock();
    }
  }

  // Health check
  async healthCheck(): Promise<boolean> {
    try {
      const response = await fetch(`${this.baseUrl}/health`);
      return response.ok;
    } catch {
      return false;
    }
  }
}
