import {exec, ExecException} from "child_process";

function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

export function runCommand(command: string): Promise<{ stdout: string, stderr: string, error: ExecException }> {
    const cmd = `powershell -NoProfile -ExecutionPolicy Bypass -Command "${command}"`;
    return new Promise((resolve, reject) => {
        exec(cmd, (error, stdout, stderr) => {
            resolve({stdout, stderr, error});
        });
    });
}

export async function waitForDocker() {
    while (true) {
        if ((await runCommand('docker info')).error) {
            await sleep(1000);
        } else {
            break;
        }
    }

}
