declare global {
  interface Window {
    bl1nk?: { flags: { ENABLE_SHARE_UI: boolean } };
  }
}

const btn = document.getElementById('shareBtn') as HTMLButtonElement;
const menu = document.getElementById('shareMenu') as HTMLDivElement;

const enableShare = !!window.bl1nk?.flags.ENABLE_SHARE_UI;

if (enableShare) {
  btn.disabled = false;
  btn.title = 'Share / Export / Publish';

  btn.addEventListener('click', () => {
    const visible = menu.style.display === 'block';
    menu.style.display = visible ? 'none' : 'block';
    menu.setAttribute('aria-hidden', String(visible));
  });

  menu.addEventListener('click', (e) => {
    const target = e.target as HTMLElement;
    const action = target.getAttribute('data-action');
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

const enableChat = !!window.bl1nk?.flags.ENABLE_CHAT_UI;

function addMessage(role: 'user' | 'assistant', text: string) {
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

  chatSend.addEventListener('click', () => {
    const text = chatInput.value.trim();
    if (!text) return;
    addMessage('user', text);
    // Placeholder assistant echo to mimic basic behavior; no backend wiring yet
    setTimeout(() => addMessage('assistant', `Echo: ${text}`), 200);
    chatInput.value = '';
    chatInput.focus();
  });

  chatInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') chatSend.click();
  });
}
