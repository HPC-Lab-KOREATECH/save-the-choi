declare global {
    interface Window {
        electronBridge: {
            closeWindow: () => void;
            // 필요한 경우 여기에 추가적인 메서드나 프로퍼티를 선언하세요.
        };
    }
}

export {};