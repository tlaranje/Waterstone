const { app, BrowserWindow, globalShortcut } = require('electron');

let win;

const createWindow = () => {
  win = new BrowserWindow({
    width: 800,
    height: 600,
    transparent: true,
    frame: false,
    alwaysOnTop: true
  });

  win.loadFile('src/index.html');

  const ret = globalShortcut.register('ESC', () => {
      app.quit();
  });

  if (!ret) {
    console.log('Falha no registro do atalho');
  }
};

app.whenReady().then(createWindow);

app.on('will-quit', () => {
  globalShortcut.unregisterAll();
});
