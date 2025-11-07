export {};

const btn = document.getElementById('shareBtn') as HTMLButtonElement;
const menu = document.getElementById('shareMenu') as HTMLDivElement;
const modelSelect = document.getElementById('modelSelect') as HTMLSelectElement;
const clearChatBtn = document.getElementById('clearChat') as HTMLButtonElement;

// Access flags from preload safely without relying on global augmentation types
type Flags = { ENABLE_SHARE_UI: boolean; ENABLE_CHAT_UI: boolean };
const bl1nk = (window as any).bl1nk as { flags: Flags } | undefined;

const enableShare = !!bl1nk?.flags.ENABLE_SHARE_UI;

if (enableShare) {
  btn.disabled = false;
  btn.title = 'Share / Export / Publish';

  btn.addEventListener('click', () => {
    const visible = menu.style.display === 'block';
    menu.style.display = visible ? 'none' : 'block';
    menu.setAttribute('aria-hidden', String(visible));
  });

  menu.addEventListener('click', (e) => {
    const actionEl = (e.target as HTMLElement).closest('[data-action]') as HTMLElement | null;
    if (!actionEl) return;
    const action = actionEl.getAttribute('data-action');
    if (action) {
      alert(`${action}: Coming soon`);
      menu.style.display = 'none';
      menu.setAttribute('aria-hidden', 'true');
    }
  });

  document.addEventListener('click', (e) => {
    if (!menu.contains(e.target as Node) && e.target !== btn) {
      menu.style.display = 'none';
      menu.setAttribute('aria-hidden', 'true');
    }
  });
}

// --- Chat preview parity (disabled by default; flag unlocks basic local echo) ---
const chatBox = document.getElementById('chatBox') as HTMLDivElement;
const chatInput = document.getElementById('chatInput') as HTMLInputElement;
const chatSend = document.getElementById('chatSend') as HTMLButtonElement;

const enableChat = !!bl1nk?.flags.ENABLE_CHAT_UI;

type ChatMessage = { role: 'user' | 'assistant'; text: string; ts: number; model?: string };
let messages: ChatMessage[] = [];

function loadMessages() {
  try {
    const raw = localStorage.getItem('chat.messages');
    messages = raw ? (JSON.parse(raw) as ChatMessage[]) : [];
  } catch {
    messages = [];
  }
}

function saveMessages() {
  localStorage.setItem('chat.messages', JSON.stringify(messages));
}

function renderMessages() {
  chatBox.innerHTML = '';
  for (const m of messages) {
    const row = document.createElement('div');
    row.style.margin = '6px 0';
    row.innerHTML = `<strong>${m.role}${m.model ? ' [' + m.model + ']' : ''}:</strong> ${m.text}`;
    chatBox.appendChild(row);
  }
  chatBox.scrollTop = chatBox.scrollHeight;
}

function addMessage(role: 'user' | 'assistant', text: string, model?: string) {
  messages.push({ role, text, ts: Date.now(), model });
  saveMessages();
  renderMessages();
}

function clearMessages() {
  messages = [];
  saveMessages();
  renderMessages();
}

function initModelSelect() {
  const saved = localStorage.getItem('chat.model');
  if (saved) modelSelect.value = saved;
  modelSelect.addEventListener('change', () => {
    localStorage.setItem('chat.model', modelSelect.value);
  });
}

loadMessages();
renderMessages();
initModelSelect();

function addMessageRow(role: 'user' | 'assistant', text: string) {
  const row = document.createElement('div');
  row.style.margin = '6px 0';
  row.innerHTML = `<strong>${role}:</strong> ${text}`;
  chatBox.appendChild(row);
  chatBox.scrollTop = chatBox.scrollHeight;
}

if (enableChat) {
  chatInput.disabled = false;
  chatInput.title = '';
  chatSend.disabled = false;
  chatSend.title = '';
  clearChatBtn.addEventListener('click', () => clearMessages());

  chatSend.addEventListener('click', () => {
    const text = chatInput.value.trim();
    if (!text) return;
    const model = modelSelect.value;
    addMessage('user', text, model);
    // Placeholder assistant echo to mimic basic behavior; no backend wiring yet
    setTimeout(() => addMessage('assistant', `Echo: ${text}`, model), 200);
    chatInput.value = '';
    chatInput.focus();
  });

  chatInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') chatSend.click();
  });
}
