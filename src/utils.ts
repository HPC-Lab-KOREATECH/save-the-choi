import {exec, ExecException} from "child_process";
import * as process from "process";

function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

export function runCommand(command: string, timeout: number = 0): Promise<{ stdout: string, stderr: string, error: ExecException }> {
    const cmd = `powershell -NoProfile -ExecutionPolicy Bypass -Command "${command}"`;
    return new Promise((resolve, reject) => {
        let timeoutInterval = -1;
        if (timeout > 0) {
            timeoutInterval = setTimeout(_ => {
                resolve({stdout: 'timeout', stderr: 'timeout', error: new Error('timeout')});
            }, timeout);
        }
        exec(cmd, (error, stdout, stderr) => {
            if (timeout > 0) {
                clearInterval(timeoutInterval);
            }
            resolve({stdout, stderr, error});
        });
    });
}

export async function isDockerNotRunning() {
    return (await runCommand('docker info')).error;
}

export async function waitForDocker() {
    while (true) {
        if (await isDockerNotRunning()) {
            await sleep(1000);
        } else {
            break;
        }
    }
}
