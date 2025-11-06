const btn = document.getElementById('shareBtn');
const menu = document.getElementById('shareMenu');
const modelSelect = document.getElementById('modelSelect');
const clearChatBtn = document.getElementById('clearChat');
const bl1nk = window.bl1nk;
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
        const target = e.target;
        const action = target.getAttribute('data-action');
        if (action) {
            alert(`${action}: Coming soon`);
            menu.style.display = 'none';
            menu.setAttribute('aria-hidden', 'true');
        }
    });
    document.addEventListener('click', (e) => {
        if (!menu.contains(e.target) && e.target !== btn) {
            menu.style.display = 'none';
            menu.setAttribute('aria-hidden', 'true');
        }
    });
}
// --- Chat preview parity (disabled by default; flag unlocks basic local echo) ---
const chatBox = document.getElementById('chatBox');
const chatInput = document.getElementById('chatInput');
const chatSend = document.getElementById('chatSend');
const enableChat = !!bl1nk?.flags.ENABLE_CHAT_UI;
let messages = [];
/**
 * Load chat messages from localStorage; returns empty list on error.
 */
function loadMessages() {
    try {
        const raw = localStorage.getItem('chat.messages');
        messages = raw ? JSON.parse(raw) : [];
    }
    catch {
        messages = [];
    }
}
/**
 * Persist messages to localStorage.
 */
function saveMessages() {
    localStorage.setItem('chat.messages', JSON.stringify(messages));
}
/**
 * Re-render the chat window from in-memory messages.
 */
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
/**
 * Append a message to the conversation and refresh the view.
 */
function addMessage(role, text, model) {
    messages.push({ role, text, ts: Date.now(), model });
    saveMessages();
    renderMessages();
}
/**
 * Clear all messages from memory and storage.
 */
function clearMessages() {
    messages = [];
    saveMessages();
    renderMessages();
}
/**
 * Initialize the model dropdown and persist selection.
 */
function initModelSelect() {
    const saved = localStorage.getItem('chat.model');
    if (saved)
        modelSelect.value = saved;
    modelSelect.addEventListener('change', () => {
        localStorage.setItem('chat.model', modelSelect.value);
    });
}
loadMessages();
renderMessages();
initModelSelect();
/**
 * Append a single DOM row to the chat window.
 */
function addMessageRow(role, text) {
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
        if (!text)
            return;
        const model = modelSelect.value;
        addMessage('user', text, model);
        // Placeholder assistant echo to mimic basic behavior; no backend wiring yet
        setTimeout(() => addMessage('assistant', `Echo: ${text}`, model), 200);
        chatInput.value = '';
        chatInput.focus();
    });
    chatInput.addEventListener('keydown', (e) => {
        if (e.key === 'Enter')
            chatSend.click();
    });
}
export {};
