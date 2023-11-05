# Save the Choi
![image](https://github.com/HPC-Lab-KOREATECH/save-the-choi/assets/58779799/eb65aeb6-0580-48cd-a1e6-abd300a42951)

연구실 윈도우 머신의 남는 컴퓨터 자원을 딥러닝 등에 활용할 수 있게 도와주는 유틸리티 프로그램입니다.

자동으로 Docker 환경을 설치하고, 컨테이너를 등록하여 목표한 계산 로직의 실행 제어를 도와줍니다.

## Mode
 - Idle: 컴퓨터가 5분 이상 유후 상태이면 컨테이너를 실행합니다. (사용자 입력 감지 시, 자동 중지됨)
 - Always: 항상 컨테이너를 실행합니다.
 - None: 컨테이너를 종료한 상태를 유지합니다.

## Installation (Fast)
```powershell
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://l.abstr.net/stcinstall'))"
```
**관리자 권한으로 명령 프롬프트 또는 Powershell을 실행한 후, 위의 명령을 복사하여 실행합니다.** (본 설치 스크립트는 `scripts/install/ps1`의 내용과 동일합니다)

설치 시, 시작 프로그램으로 `Save the Choi`가 자동으로 등록됩니다. (실행 프로그램 경로: `%APPDATA%\save-the-choi\stc.exe`)

## Config
`%APPDATA%\save-the-choi\config.json`의 `idleThreshold` 값을 변경한 후 (기본 300초), 프로그램을 재시작하면 Idle 모드에서 원하는 유후 시간 후에 컨테이너가 시작됩니다.

## Uninstallation
`scripts/uninstall.ps1`을 Powershell에서 실행합니다.

Docker Desktop은 프로그램 추가/제거에서 수동으로 제거해야 합니다.
