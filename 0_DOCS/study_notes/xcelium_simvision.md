# Cadence Xcelium & SimVision

## Xcelium — RTL 시뮬레이터
- Verilog/SystemVerilog RTL을 컴파일하고 이벤트 기반으로 시뮬레이션하는 Cadence의 시뮬레이터

### 기본 실행 흐름 (xrun)
```bash
xrun -access +rwc tb_top.v dut.v -R
```
- `-access +rwc`: 파형 뷰어(SimVision)에서 신호를 읽고(read)/쓰고(write)/제어(control)할 수 있게 접근 권한 부여
- `-R`: 컴파일 후 즉시 실행(run)

### 본 프로젝트의 Makefile 패턴
- 각 RTL 디렉터리에 `Makefile` + `run.tcl` + `clean.tcl`을 두고, `make` 한 번으로 컴파일→시뮬레이션→파형 생성까지 처리
- `clean.tcl`: 시뮬레이션 부산물(`.log`, `.history`, `xcelium.d` 등) 정리

## SimVision — 파형 뷰어
- Xcelium이 생성한 파형(shm/vcd 등)을 GUI로 확인하는 도구
- `.simvision/` 폴더에 북마크(`dbrowser-bookmarks`, `schematic-bookmarks`, `source-bookmarks`)가 저장되어, 다음에 열 때 이전에 보던 신호 배치를 그대로 복원 가능

### 주요 사용 패턴
1. 신호 추가: Design Browser에서 원하는 모듈의 신호를 Waveform 창으로 드래그
2. 자주 보는 신호 묶음을 그룹으로 저장 → `.simvision/*-bookmarks`에 반영
3. Schematic 뷰로 게이트 레벨 연결 관계 확인 (합성 후 netlist 디버깅 시 유용)

## 디버깅 팁
- `$monitor`로 콘솔에서 1차로 이상 유무를 빠르게 확인 → 문제 구간만 SimVision 파형으로 정밀 분석하는 순서가 효율적
- UART처럼 타이밍이 중요한 설계는 baud rate 주기 단위로 커서를 이동시키며 비트 단위로 확인

## 본 프로젝트 연관
- Verification 섹션에 명시된 "Cadence Xcelium + SimVision" 조합이 RTL simulation 전 과정의 표준 툴체인
