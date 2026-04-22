const path = require('path');
const { app, BrowserWindow, globalShortcut, screen, ipcMain } = require('electron');

try {
  require('electron-reload')(__dirname, {
    electron: path.join(__dirname, '../node_modules', '.bin', 'electron'),
    hardResetMethod: 'exit'
  });
} catch (err) {
  console.log('electron-reload could not be started');
}

let overlayWin;
let hitWin;

const createWindows = () => {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;

  // ─── Overlay window (visual only, always ignores mouse) ────────────────────
  overlayWin = new BrowserWindow({
    width, height,
    transparent: true,
    frame: false,
    alwaysOnTop: true,
    skipTaskbar: true,
    focusable: false,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  overlayWin.loadFile('src/index.html');
  overlayWin.setIgnoreMouseEvents(true, { forward: true });

  // ─── Hit window (invisible, 1x1 by default, expands over buttons) ──────────
  hitWin = new BrowserWindow({
    width: 1,
    height: 1,
    x: -100,
    y: -100,
    transparent: true,
    frame: false,
    alwaysOnTop: true,
    skipTaskbar: true,
    focusable: true,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  hitWin.loadFile('src/hit.html');
  hitWin.setIgnoreMouseEvents(false);
  hitWin.on('blur', () => hitWin.setAlwaysOnTop(true, 'screen-saver'));

  // ─── Shortcuts ─────────────────────────────────────────────────────────────
  globalShortcut.register('ctrl+1', () => {
    if (overlayWin.isVisible()) {
      overlayWin.hide();
      hitWin.setBounds({ x: -100, y: -100, width: 1, height: 1 });
    } else {
      overlayWin.show();
    }
  });

  globalShortcut.register('ESC', () => app.quit());
};

// ─── IPC: Mouse is over a button → expand hit window over it ───────────────
ipcMain.on('mouse-over-button', (event, bounds) => {
  hitWin.setBounds({
    x: Math.round(bounds.x),
    y: Math.round(bounds.y),
    width: Math.round(bounds.width),
    height: Math.round(bounds.height)
  });
});

// ─── IPC: Mouse left all buttons → shrink hit window away ──────────────────
ipcMain.on('mouse-over-none', () => {
  hitWin.setBounds({ x: -100, y: -100, width: 1, height: 1 });
});

// ─── IPC: Forward click from hit window to overlay ─────────────────────────
ipcMain.on('button-clicked', (event, id) => {
  overlayWin.webContents.send('button-clicked', id);
});

app.whenReady().then(createWindows);
app.on('will-quit', () => globalShortcut.unregisterAll());
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});