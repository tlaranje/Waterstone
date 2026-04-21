const path = require('path');
const {
  app,
  BrowserWindow,
  globalShortcut,
  screen,
  ipcMain
} = require('electron');

try {
  require('electron-reload')(__dirname, {
    electron: path.join(__dirname, '../node_modules', '.bin', 'electron'),
    hardResetMethod: 'exit'
  });
} catch (err) {
  console.log("Electron reload não pôde ser iniciado");
}

let win;

const createWindow = () => {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize;

  win = new BrowserWindow({
    width: width,
    height: height,
    transparent: true,
    frame: false,
    alwaysOnTop: true,
    focusable: false,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  win.loadFile('src/index.html');
  win.setIgnoreMouseEvents(true, { forward: true });

  const ret1 = globalShortcut.register('ctrl+one', () => {

  });
  if (win.isVisible()) {
    win.hide();
  } else {
    win.show();
  }
  const ret = globalShortcut.register('ESC', () => {
    app.quit()
  });

  if (!ret) {
    console.log('Falha no registro do atalho');
  }
};

ipcMain.on('set-ignore-mouse', (event, ignore) => {
  const targetWin = BrowserWindow.fromWebContents(event.sender);
  if (targetWin) {
    // Adicione um log para conferir se o comando está chegando
    // console.log("Ignorar mouse:", ignore);
    targetWin.setIgnoreMouseEvents(ignore, { forward: true });
  }
});

app.whenReady().then(createWindow);

app.on('will-quit', () => {
  globalShortcut.unregisterAll();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
