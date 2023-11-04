import {app, BrowserWindow, ipcMain, Menu, Tray} from "electron";
import * as path from "path";
import * as fs from 'fs';
import {runCommand, waitForDocker} from "./utils";
import * as process from "process";
import logger from 'electron-log/main';
import {Config, DockerConfig, Mode} from "./types/types";
import {getIdleTime} from 'desktop-idle';

/** Init & Config **/
logger.initialize({preload: true});
const rootPath = `${path.dirname(app.getPath("userData"))}/save-the-choi`;
const configPath = `${rootPath}/config.json`;
const dockerConfigPath = `${rootPath}/docker-config.json`;
let config: Config;
let dockerConfig: DockerConfig = JSON.parse(fs.readFileSync(dockerConfigPath, 'utf8').trim());
const saveConfig = (newConfig: Config) => {
    logger.info(`saveConfig(${JSON.stringify(newConfig)})`);
    config = newConfig;
    fs.writeFileSync(configPath, JSON.stringify(config), 'utf8');
};

if (!fs.existsSync(configPath)) {
    saveConfig({
        status: 'installation',
        mode: 'idle',
        idleEnabled: false,
        idleThreshold: 300,
        idleTime: 0,
        totalTime: 0
    });
} else {
    config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
}

let isChangingMode = false;
const changeMode = async (mode: Mode) => {
    if (isChangingMode) return;
    isChangingMode = true;

    logger.info(`changeMode(${mode})`);

    tray.setToolTip('Save the Choi (Changing Mode)');
    updateTrayMenu(false);

    if (mode === 'none' || mode === 'idle') {
        await runCommand(`docker stop ${dockerConfig.containerName}`);
        config.idleEnabled = false;
    } else if (mode === 'always') {
        await runCommand(`docker start ${dockerConfig.containerName}`);
    }
    saveConfig({...config, mode});
    mainWindow.webContents.send('updateConfig', config);

    isChangingMode = false;
    tray.setToolTip('Save the Choi');
    updateTrayMenu(true);
}

/** UI **/
let mainWindow: BrowserWindow;
let tray: Tray;
let isTrayClosing = false;
ipcMain.on('start', async (event) => {
    config.status = 'initialized';
    await changeMode('idle');
    mainWindow.setSize(400, 330, true);
    await mainWindow.loadFile(path.join(__dirname, "../main.html"));
});
ipcMain.on('requestUpdateConfig', (event) => {
    mainWindow.webContents.send('updateConfig', config);
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
    if (config.status === 'installation') {
        mainWindow.loadFile(path.join(__dirname, "../intro.html")).then();
    } else {
        mainWindow.setSize(400, 330, true);
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

function updateTrayMenu(enabled = true) {
    const contextMenu = Menu.buildFromTemplate([
        {
            label: 'Idle',
            type: 'radio',
            click: _ => changeMode('idle'),
            checked: config.mode === 'idle',
            enabled
        },
        {
            label: 'Always',
            type: 'radio',
            click: _ => changeMode('always'),
            checked: config.mode === 'always',
            enabled
        },
        {
            label: 'None',
            type: 'radio',
            click: _ => changeMode('none'),
            checked: config.mode === 'none',
            enabled
        },
        {
            label: 'Close', click: _ => {
                isTrayClosing = true;
                app.quit();
            }
        }
    ]);
    tray.setContextMenu(contextMenu);
    trayEnabled = enabled;
}

let trayEnabled = false;

function createTray() {
    tray = new Tray('./resources/stc.png');
    updateTrayMenu();
    tray.setToolTip('Save the Choi');
    tray.on('click', _ => {
        if (mainWindow.isVisible()) {
            mainWindow.hide();
        } else if (trayEnabled) {
            mainWindow.webContents.send('updateConfig', config);
            mainWindow.show();
        }
    });
}

let lastTime = new Date();
setInterval(async _ => {
    config.idleTime = getIdleTime();
    if (config.idleTime > config.idleThreshold) {
        if (!config.idleEnabled) {
            config.idleEnabled = true;
            await runCommand(`docker start ${dockerConfig.containerName}`);
        }
    } else {
        if (config.idleEnabled) {
            config.idleEnabled = false;
            await runCommand(`docker stop ${dockerConfig.containerName}`);
        }
    }
    if (config.mode === 'always' || (config.mode === 'idle' && config.idleEnabled)) {
        config.totalTime += new Date().getTime() - lastTime.getTime();
    }
    if (mainWindow.isVisible()) {
        mainWindow.webContents.send('updateConfig', config);
    }
    lastTime = new Date();
}, 300);
setInterval(_ => {
    saveConfig(config);
}, 1000 * 15);

/** Launch **/
const gotTheLock = app.requestSingleInstanceLock();
if (!gotTheLock) {
    logger.info('The instance is already running. Quit.');
    app.quit();
} else {
    app.on('second-instance', (event, commandLine, workingDirectory) => {
        if (mainWindow) {
            if (mainWindow.isMinimized()) mainWindow.restore();
            if (!mainWindow.isVisible()) mainWindow.show();
            mainWindow.focus();
        }
    });
    app.whenReady().then(async _ => {
        createWindow();
        createTray();

        updateTrayMenu(false);
        tray.setToolTip('Save the Choi (Wait for Docker)');
        logger.info('Wait for Docker');
        await waitForDocker();
        if (config.status === 'installation') {
            logger.info('Status: Installation');
            tray.setToolTip('Save the Choi (Installation)');
            await runCommand(`docker rm --force ${dockerConfig.containerName}`);
            await runCommand(`docker rmi --force ${dockerConfig.imageName}`);
            await runCommand(`docker load -i ${rootPath}/image.tar`);
            if (dockerConfig.containerCreationCommand) {
                await runCommand(dockerConfig.containerCreationCommand);
            } else {
                await runCommand(`docker create -it --entrypoint "/opt/run.sh" --name ${dockerConfig.containerName} ${dockerConfig.imageName}`);
            }
            await runCommand(dockerConfig.containerCreationCommand);
            mainWindow.show();
        }

        updateTrayMenu(true);
        tray.setToolTip('Save the Choi');
        await changeMode(config.mode);

        app.on("activate", function () {
            if (BrowserWindow.getAllWindows().length === 0) createWindow();
        });
    });

    app.on("window-all-closed", () => {
        if (process.platform !== "darwin") {
            app.quit();
        }
    });
}
