# Save the Choi

![image](https://github.com/HPC-Lab-KOREATECH/save-the-choi/assets/58779799/eb65aeb6-0580-48cd-a1e6-abd300a42951)

연구실 윈도우 머신의 남는 컴퓨터 자원을 딥러닝 등에 활용할 수 있게 도와주는 유틸리티 프로그램입니다.

자동으로 Docker 환경을 설치하고, 컨테이너를 등록하여 목표한 계산 로직의 실행 제어를 도와줍니다.

## Mode

- IDLE (설치 시 기본 값): 컴퓨터가 5분 이상 유휴 상태이면 컨테이너를 실행합니다. (사용자 입력 감지 시, 자동 중지됨)
- ALWAYS: 항상 컨테이너를 실행합니다.
- NONE: 컨테이너를 종료한 상태를 유지합니다.

## Installation (Quickstart)

### Windows

#### Install
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://l.hpclab.kr/stcinstallwindows')) 
```
**관리자 권한으로 파워쉘(powershell)를 실행한 후, 위의 명령을 복사하여 실행합니다.** (본 설치 스크립트는 `scripts/windows/install.ps1`의 내용과 동일합니다)

권한 등의 오류로 실행이 되지 않는 경우, powershell.exe를 통한 설치를 권장합니다.

설치 시, 시작 프로그램과 시작 메뉴에 `Save the Choi`가 자동으로 등록됩니다. (실행 프로그램 경로: `%APPDATA%\save-the-choi\stc.exe`)

#### Update (이미 설치한 경우, 버전 업데이트)
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://l.hpclab.kr/stcupdatewindows')) 
```
**관리자 권한으로 파워쉘(powershell)를 실행한 후, 위의 명령을 복사하여 실행합니다.** (본 설치 스크립트는 `scripts/windows/update.ps1`의 내용과 동일합니다)

권한 등의 오류로 실행이 되지 않는 경우, powershell.exe를 통한 설치를 권장합니다.

설치 시, 시작 프로그램과 시작 메뉴에 `Save the Choi`가 자동으로 등록됩니다. (실행 프로그램 경로: `%APPDATA%\save-the-choi\stc.exe`)

### Linux

```bash
curl -Ls https://l.hpclab.kr/stcinstalllinux | sudo bash && /opt/stc/run.sh
```

**설치를 원하는 계정의 그래픽 세션에서 해당 명령을 터미널에 복사하여 실행합니다.** (본 설치 스크립트는 `scripts/linux/install.sh`의 내용과 동일합니다)

그래픽 세션이 아닌 경우, 설치는 가능하지만 그래픽 세션이 시작될 때 프로그램이 실행됩니다.

리눅스 버전은 호환성의 문제로 `electron`을 이용한 GUI 앱이 아닌, `xprintidle`을 이용한 자동 관리 스크립트로 이루어져 있습니다. (실행 프로그램 경로: `/opt/stc/run.sh`)

설치 시, 그래픽 세션의 시작 프로그램(`~/.config/autostart/stc.desktop`)으로 자동으로 등록됩니다.

## How to use?

### Windows

설치가 완료된 뒤, 재부팅 후 최초로 프로그램이 실행되면 컨테이너를 자동으로 설정합니다.

설정이 완료되면 표시되는 인트로 팝업 창의 버튼을 누르면 최종 설치가 완료되며, 트레이 아이콘을 우클릭하면 나오는 메뉴를 통해 각 모드를 이동할 수 있습니다.

트레이 아이콘을 누르게 되면, 현재 상태가 표시됩니다.

### Linux

(그래픽 세션에서) 설치가 완료되면, 프로그램이 자동으로 시작됩니다.

사용자는 스크립트 명령을 통해, 프로그램의 실행/종료, 모드를 제어할 수 있습니다.

`/opt/stc/run.sh`: 프로그램 시작

`/opt/stc/stop.sh`: 프로그램 종료

`/opt/stc/idle.sh <idleThreshold (기본 값: 300)>`: idle 상태로 프로그램을 설정합니다.

`/opt/stc/always.sh`: always 상태로 프로그램을 설정합니다.

`/opt/stc/none.sh`: none 상태로 프로그램을 설정합니다.

## Config

### Windows

트레이 아이콘을 우클릭한 메뉴를 통해 `Idle`, `Always`, `None` 모드 변경이 가능합니다.

`%APPDATA%\save-the-choi\config.json`의 `idleThreshold` 값을 변경한 후 (기본 300초), 프로그램을 재시작하면 Idle 모드에서 원하는 유휴 시간 후에 컨테이너가
시작됩니다.

### Linux

`/opt/stc/config.json`의 `idleThreshold` 값을 변경하면 (기본 300초) 설정이 즉시 적용되며, Idle 모드에서 원하는 유휴 시간 후에 컨테이너가 시작됩니다. (모드 변경 스크립트 이용 권장)

#### Scripts

다음 모드 변경 스크립트를 통해 모드 변경이 가능합니다.

`/opt/stc/idle.sh <idleThreshold (기본 값: 300)>`: idle 상태로 프로그램을 설정합니다.

`/opt/stc/always.sh`: always 상태로 프로그램을 설정합니다.

`/opt/stc/none.sh`: none 상태로 프로그램을 설정합니다.

## Uninstallation

### Windows
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://l.hpclab.kr/stcuninstallwindows')) 
```

**관리자 권한으로 파워쉘(powershell)를 실행한 후, 위의 명령을 복사하여 실행합니다.** (본 설치 스크립트는 `scripts/windows/uninstall.ps1`의 내용과 동일합니다)

Docker Desktop은 프로그램 추가/제거에서 수동으로 제거해야 합니다.

### Linux
```bash
curl -Ls https://l.hpclab.kr/stcuninstalllinux | sudo bash
```

**해당 명령을 터미널에 복사하여 실행합니다.** (본 설치 스크립트는 `scripts/linux/uninstall.sh`의 내용과 동일합니다)

Docker는 패키지 관리 프로그램 또는 apt를 이용하여 수동으로 제거해야 합니다.
