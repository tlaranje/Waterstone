const { ipcRenderer } = require('electron');

// Forward the click to the overlay renderer via main process
document.getElementById('hit-area').onclick = () => {
  // Get button id from the last mouse-over-button message
  ipcRenderer.send('button-clicked', currentId);
};

let currentId = null;

ipcRenderer.on('set-current-id', (event, id) => {
  currentId = id;
});