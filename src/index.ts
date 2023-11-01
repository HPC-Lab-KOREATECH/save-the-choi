import {app, BrowserWindow, Tray, Menu, ipcMain} from "electron";
import * as path from "path";
import * as fs from 'fs';
import {Status} from "./types";

const configPath = `${path.dirname(app.getPath("exe"))}/config.json`;
console.log(configPath);
if (!fs.existsSync(configPath)) {
    fs.writeFileSync(configPath, JSON.stringify({status: 'installation'}), 'utf8');
}
let config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));
const saveConfig = (c: any) => {
    fs.writeFileSync(configPath, JSON.stringify(c), 'utf8');
};
let mainWindow: BrowserWindow;
let tray: Tray;
let isTrayClosing = false;
ipcMain.on('start-button', (event) => {
    const win = BrowserWindow.fromWebContents(event.sender);
    win.hide();
});

function createWindow() {
    mainWindow = new BrowserWindow({
        icon: './resources/stc.png',
        height: 700,
        webPreferences: {
            preload: path.join(__dirname, "preload.js"),
            nodeIntegration: false,
            contextIsolation: true,
        },
        width: 1000,
        show: false
    });
    mainWindow.setMenu(null);
    if(config.status === Status.INSTALLATION) {
        mainWindow.loadFile(path.join(__dirname, "../intro.html")).then();
    } else {
        mainWindow.loadFile(path.join(__dirname, "../main.html")).then();
    }
    mainWindow.on('close', function (e) {
        if (!isTrayClosing) {
            e.preventDefault();
            mainWindow.hide();
        }
    });
    // mainWindow.webContents.openDevTools();
}

function createTray() {
    tray = new Tray('./resources/stc.png');

    const contextMenu = Menu.buildFromTemplate([
        {label: 'Main', click: () => {}},
        {label: 'Idle', click: () => mainWindow.show()},
        {label: 'Always', click: () => mainWindow.show()},
        {label: 'None', click: () => mainWindow.show()},
        {
            label: 'Close', click: () => {
                isTrayClosing = true;
                app.quit();
            }
        }
    ]);

    tray.setToolTip('Save the Choi');
    tray.setContextMenu(contextMenu);
    tray.on('click', () => {
        if (mainWindow.isVisible()) {
            mainWindow.hide();
        } else {
            mainWindow.show();
        }
    });
}

app.whenReady().then(() => {
    createWindow();
    createTray();
    if (config.status === Status.INSTALLATION) {
        tray.setToolTip('Save the Choi (Installing)');
        // Install logic
        saveConfig({status: Status.IDLE});
        tray.setToolTip('Save the Choi (IDLE)');
    }

    app.on("activate", function () {
        if (BrowserWindow.getAllWindows().length === 0) createWindow();
    });
});

app.on("window-all-closed", () => {
    if (process.platform !== "darwin") {
        app.quit();
    }
});
