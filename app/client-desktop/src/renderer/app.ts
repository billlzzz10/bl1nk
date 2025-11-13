// Main application logic for bl1nk Desktop
import { ApiClient } from '../api-client.js';
import type { ChatThread, ChatMessage, MessageStreamEvent, FeatureFlags } from '../types.js';

declare global {
  interface Window {
    bl1nk?: {
      flags: FeatureFlags;
      getConfig: () => Promise<{ apiBaseUrl: string; redisUrl: string; qdrantUrl: string }>;
      getFeatureFlags: () => Promise<FeatureFlags>;
      storeAuthToken: (token: string) => Promise<boolean>;
      getAuthToken: () => Promise<string | null>;
      clearAuthToken: () => Promise<boolean>;
    };
  }
}

export class App {
  private apiClient: ApiClient | null = null;
  private currentWorkspaceId: string | null = null;
  private currentThreadId: string | null = null;
  private threads: ChatThread[] = [];
  private messages: ChatMessage[] = [];
  private featureFlags: FeatureFlags;

  // DOM Elements
  private statusBadge: HTMLElement;
  private threadList: HTMLElement;
  private chatMessages: HTMLElement;
  private chatInput: HTMLTextAreaElement;
  private sendBtn: HTMLButtonElement;
  private newThreadBtn: HTMLButtonElement;
  private clearChatBtn: HTMLButtonElement;
  private chatTitle: HTMLElement;
  private chatSubtitle: HTMLElement;
  private modelSelect: HTMLSelectElement;
  private featureStatus: HTMLElement;

  constructor() {
    // Get DOM elements
    this.statusBadge = document.getElementById('statusBadge')!;
    this.threadList = document.getElementById('threadList')!;
    this.chatMessages = document.getElementById('chatMessages')!;
    this.chatInput = document.getElementById('chatInput') as HTMLTextAreaElement;
    this.sendBtn = document.getElementById('sendBtn') as HTMLButtonElement;
    this.newThreadBtn = document.getElementById('newThreadBtn') as HTMLButtonElement;
    this.clearChatBtn = document.getElementById('clearChatBtn') as HTMLButtonElement;
    this.chatTitle = document.getElementById('chatTitle')!;
    this.chatSubtitle = document.getElementById('chatSubtitle')!;
    this.modelSelect = document.getElementById('modelSelect') as HTMLSelectElement;
    this.featureStatus = document.getElementById('featureStatus')!;

    // Get feature flags
    this.featureFlags = window.bl1nk?.flags || { ENABLE_SHARE_UI: false, ENABLE_CHAT_UI: false };

    this.init();
  }

  private async init() {
    // Initialize API client
    try {
      const config = await window.bl1nk?.getConfig();
      if (config) {
        this.apiClient = new ApiClient({ baseUrl: config.apiBaseUrl });
        await this.checkConnection();
      }
    } catch (error) {
      console.error('Failed to initialize API client:', error);
      this.updateStatus('offline');
    }

    // Set up event listeners
    this.setupEventListeners();

    // Update UI based on feature flags
    this.updateFeatureStatus();

    // Load saved data
    this.loadLocalData();
  }

  private setupEventListeners() {
    // Send message
    this.sendBtn.addEventListener('click', () => this.sendMessage());
    this.chatInput.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        this.sendMessage();
      }
    });

    // Auto-resize textarea
    this.chatInput.addEventListener('input', () => {
      this.chatInput.style.height = 'auto';
      this.chatInput.style.height = Math.min(this.chatInput.scrollHeight, 120) + 'px';
    });

    // New thread
    this.newThreadBtn.addEventListener('click', () => this.createNewThread());

    // Clear chat
    this.clearChatBtn.addEventListener('click', () => this.clearCurrentChat());

    // Model selection
    this.modelSelect.addEventListener('change', () => {
      localStorage.setItem('selectedModel', this.modelSelect.value);
    });

    // Load saved model
    const savedModel = localStorage.getItem('selectedModel');
    if (savedModel) {
      this.modelSelect.value = savedModel;
    }
  }

  private async checkConnection() {
    if (!this.apiClient) return;

    try {
      const isHealthy = await this.apiClient.healthCheck();
      this.updateStatus(isHealthy ? 'online' : 'offline');
    } catch {
      this.updateStatus('offline');
    }
  }

  private updateStatus(status: 'online' | 'offline') {
    this.statusBadge.textContent = status;
    this.statusBadge.className = `status-badge ${status}`;
  }

  private updateFeatureStatus() {
    if (this.featureFlags.ENABLE_CHAT_UI) {
      this.featureStatus.innerHTML = '✅ Chat features enabled';
      this.chatInput.disabled = false;
      this.sendBtn.disabled = false;
    } else {
      this.featureStatus.innerHTML = 'Set <code>ENABLE_CHAT_UI=true</code> to enable chat features';
      this.chatInput.disabled = true;
      this.sendBtn.disabled = true;
    }
  }

  private loadLocalData() {
    // Load threads from localStorage
    try {
      const savedThreads = localStorage.getItem('threads');
      if (savedThreads) {
        this.threads = JSON.parse(savedThreads);
        this.renderThreadList();
      }

      const savedMessages = localStorage.getItem('messages');
      if (savedMessages) {
        this.messages = JSON.parse(savedMessages);
        this.renderMessages();
      }
    } catch (error) {
      console.error('Failed to load local data:', error);
    }
  }

  private saveLocalData() {
    try {
      localStorage.setItem('threads', JSON.stringify(this.threads));
      localStorage.setItem('messages', JSON.stringify(this.messages));
    } catch (error) {
      console.error('Failed to save local data:', error);
    }
  }

  private async createNewThread() {
    const title = `Chat ${new Date().toLocaleString()}`;
    const thread: ChatThread = {
      id: this.generateId(),
      workspaceId: this.currentWorkspaceId || 'local',
      title,
      modelConfig: {
        provider: 'openai',
        modelId: this.modelSelect.value,
      },
      createdAt: Date.now(),
      updatedAt: Date.now(),
    };

    this.threads.unshift(thread);
    this.currentThreadId = thread.id;
    this.messages = [];

    this.saveLocalData();
    this.renderThreadList();
    this.renderMessages();
    this.updateChatHeader(thread);
  }

  private async sendMessage() {
    if (!this.featureFlags.ENABLE_CHAT_UI) return;

    const text = this.chatInput.value.trim();
    if (!text) return;

    // Create thread if none exists
    if (!this.currentThreadId) {
      await this.createNewThread();
    }

    // Create user message
    const userMessage: ChatMessage = {
      id: this.generateId(),
      threadId: this.currentThreadId!,
      workspaceId: this.currentWorkspaceId || 'local',
      role: 'user',
      text,
      status: 'completed',
      createdAt: Date.now(),
    };

    this.messages.push(userMessage);
    this.chatInput.value = '';
    this.chatInput.style.height = 'auto';
    this.renderMessages();
    this.saveLocalData();

    // Create assistant message (placeholder)
    const assistantMessage: ChatMessage = {
      id: this.generateId(),
      threadId: this.currentThreadId!,
      workspaceId: this.currentWorkspaceId || 'local',
      role: 'assistant',
      text: '',
      status: 'streaming',
      createdAt: Date.now(),
    };

    this.messages.push(assistantMessage);
    this.renderMessages();

    // Simulate streaming response (replace with actual API call)
    await this.simulateStreamingResponse(assistantMessage);
  }

  private async simulateStreamingResponse(message: ChatMessage) {
    // This is a placeholder. In production, use apiClient.streamMessage()
    const responses = [
      "I'm a placeholder response. ",
      "To enable real AI responses, ",
      "connect to the bl1nk backend server. ",
      "The API client is ready to use!",
    ];

    for (const chunk of responses) {
      await new Promise(resolve => setTimeout(resolve, 100));
      message.text += chunk;
      this.renderMessages();
    }

    message.status = 'completed';
    this.renderMessages();
    this.saveLocalData();
  }

  private clearCurrentChat() {
    if (!this.currentThreadId) return;

    if (confirm('Clear this conversation?')) {
      this.messages = this.messages.filter(m => m.threadId !== this.currentThreadId);
      this.saveLocalData();
      this.renderMessages();
    }
  }

  private renderThreadList() {
    if (this.threads.length === 0) {
      this.threadList.innerHTML = `
        <div class="empty-state">
          <div class="empty-state-icon">💬</div>
          <div class="empty-state-title">No conversations yet</div>
          <div class="empty-state-text">Start a new chat to begin</div>
        </div>
      `;
      return;
    }

    this.threadList.innerHTML = this.threads
      .map(
        thread => `
        <div class="thread-item ${thread.id === this.currentThreadId ? 'active' : ''}" data-thread-id="${thread.id}">
          <div class="thread-title">${this.escapeHtml(thread.title || 'Untitled')}</div>
          <div class="thread-meta">${new Date(thread.updatedAt).toLocaleDateString()}</div>
        </div>
      `
      )
      .join('');

    // Add click handlers
    this.threadList.querySelectorAll('.thread-item').forEach(item => {
      item.addEventListener('click', () => {
        const threadId = item.getAttribute('data-thread-id');
        if (threadId) this.selectThread(threadId);
      });
    });
  }

  private selectThread(threadId: string) {
    this.currentThreadId = threadId;
    const thread = this.threads.find(t => t.id === threadId);
    if (thread) {
      this.updateChatHeader(thread);
      this.messages = JSON.parse(localStorage.getItem('messages') || '[]').filter(
        (m: ChatMessage) => m.threadId === threadId
      );
      this.renderThreadList();
      this.renderMessages();
    }
  }

  private updateChatHeader(thread: ChatThread) {
    this.chatTitle.textContent = thread.title || 'Untitled';
    this.chatSubtitle.textContent = `Model: ${thread.modelConfig.modelId}`;
  }

  private renderMessages() {
    if (this.messages.length === 0) {
      this.chatMessages.innerHTML = `
        <div class="empty-state">
          <div class="empty-state-icon">👋</div>
          <div class="empty-state-title">Start a conversation</div>
          <div class="empty-state-text">Type a message below to begin chatting with AI</div>
        </div>
      `;
      return;
    }

    this.chatMessages.innerHTML = this.messages
      .map(
        message => `
        <div class="message ${message.role} ${message.status === 'streaming' ? 'streaming' : ''}">
          <div class="message-avatar">${message.role === 'user' ? '👤' : '🤖'}</div>
          <div class="message-content">
            <div class="message-role">${message.role === 'user' ? 'You' : 'Assistant'}</div>
            <div class="message-text">${this.escapeHtml(message.text)}</div>
          </div>
        </div>
      `
      )
      .join('');

    // Scroll to bottom
    this.chatMessages.scrollTop = this.chatMessages.scrollHeight;
  }

  private generateId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  private escapeHtml(text: string): string {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }
}

// Initialize app when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => new App());
} else {
  new App();
}
