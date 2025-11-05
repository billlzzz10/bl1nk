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

