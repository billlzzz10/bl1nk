import { app, BrowserWindow } from 'electron';
import { fileURLToPath } from 'url';
import { join, dirname } from 'path';
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
// Reduce GPU-related crashes on Linux/WSL by disabling hardware acceleration
// Can be revisited later if native GPU is desired.
// Disable GPU to reduce potential crashes in CI/WSL-like environments.
app.disableHardwareAcceleration();
app.commandLine.appendSwitch('disable-gpu');
/**
 * Create the primary BrowserWindow and load the renderer entrypoint.
 */
function createWindow() {
    const win = new BrowserWindow({
        width: 1000,
        height: 700,
        webPreferences: {
            preload: join(__dirname, 'preload.js')
        }
    });
    win.loadFile(join(__dirname, 'renderer', 'index.html'));
}
app.whenReady().then(() => {
    createWindow();
    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0)
            createWindow();
    });
});
// Quit the app when all windows are closed (except on macOS where
// apps typically remain active until the user explicitly quits).
app.on('window-all-closed', () => {
    if (process.platform !== 'darwin')
        app.quit();
});
