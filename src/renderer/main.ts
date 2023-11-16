import {Config} from "../types/types";

function millisecondsToHoursMinutesSeconds(milliseconds: number) {
    const secondsTotal = Math.floor(milliseconds / 1000);
    const seconds = secondsTotal % 60;
    const minutesTotal = Math.floor(secondsTotal / 60);
    const minutes = minutesTotal % 60;
    const hours = Math.floor(minutesTotal / 60);

    return (hours > 0 ? hours + 'h ' : '') +
        (minutes > 0 || hours > 0 ? minutes + 'm ' : '') +
        (seconds > 0 || minutes > 0 || hours > 0 ? seconds + 's' : '');
}

window.electronBridge.handleUpdateConfig((config: Config) => {
    let title = document.getElementById('title');
    title.textContent = `Mode: ${config.mode.toUpperCase()} ${config.mode === 'idle' ? '(' + config.idleTime + 's)' : ''}`
    if (config.mode === 'idle') {
        title.style.color = config.idleEnabled ? 'green' : 'grey';
    } else if (config.mode === 'always') {
        title.style.color = 'green';
    } else if (config.mode === 'none') {
        title.style.color = 'gray';
    }
    let time = document.getElementById('time');
    let timeText = millisecondsToHoursMinutesSeconds(config.totalTime);
    timeText = timeText === '' ? '0s' : timeText;
    time.textContent = timeText;
});
window.addEventListener("DOMContentLoaded", () => {
    window.electronBridge.requestUpdateConfig();
});