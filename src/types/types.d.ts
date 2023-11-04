declare global {
    interface Window {
        electronBridge: any;
    }
}


export {};

export type Status = 'installation' | 'initialized';
export type Mode = 'idle' | 'always' | 'none';

export type Config = {
    status: Status;
    mode: Mode;
    idleThreshold: number;
    idleTime: number;
    idleEnabled: boolean;
    totalTime: number;
}

export type DockerConfig = {
    imageName: string;
    containerName: string;
    containerCreationCommand: string;
}