import {contextBridge, ipcRenderer} from 'electron';

contextBridge.exposeInMainWorld('electronBridge', {
    start: () => ipcRenderer.send('start'),
    requestUpdateConfig: () => ipcRenderer.send('requestUpdateConfig'),
    handleUpdateConfig: (callback: Function) => {
        ipcRenderer.on('updateConfig', (event, ...args) => callback(...args));
    }
});

window.addEventListener("DOMContentLoaded", () => {
    const replaceText = (selector: string, text: string) => {
        const element = document.getElementById(selector);
        if (element) {
            element.innerText = text;
        }
    };

    for (const type of ["chrome", "node", "electron"]) {
        replaceText(`${type}-version`, process.versions[type as keyof NodeJS.ProcessVersions]);
    }
});
