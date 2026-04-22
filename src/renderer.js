const { ipcRenderer } = require('electron');

const container = document.getElementById('main-container');
const buttons = []; // store button metadata for hit-testing

// ─── mousemove fires even with setIgnoreMouseEvents + forward:true ──────────
// Use it to detect if cursor is over a button and reposition hit window
document.addEventListener('mousemove', (e) => {
  const el = document.elementFromPoint(e.clientX, e.clientY);

  if (el && el.dataset.buttonId) {
    const rect = el.getBoundingClientRect();
    ipcRenderer.send('mouse-over-button', {
      x: Math.round(rect.left),
      y: Math.round(rect.top),
      width: Math.round(rect.width),
      height: Math.round(rect.height),
      id: el.dataset.buttonId
    });
  } else {
    ipcRenderer.send('mouse-over-none');
  }
});

// ─── Receive click from hit window via main ─────────────────────────────────
ipcRenderer.on('button-clicked', (event, id) => {
  const btn = document.querySelector(`[data-button-id="${id}"]`);
  if (btn) {
    btn.style.backgroundColor = btn.style.backgroundColor === 'red' ? 'white' : 'red';
  }
});

// ─── Button factory ─────────────────────────────────────────────────────────
function create_button(id, text = 'Hello World!', top = 0, right = 0) {
  const btn = document.createElement('button');
  btn.innerText = text;
  btn.dataset.buttonId = id; // used for hit-testing in mousemove

  btn.style.position = 'absolute';
  btn.style.top      = top + 'px';
  btn.style.right    = right + 'px';

  container.appendChild(btn);
  return btn;
}

// ─── Init ───────────────────────────────────────────────────────────────────
create_button('btn-1', 'Hello World!', 10, 10);