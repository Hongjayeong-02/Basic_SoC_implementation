# UART (Universal Asynchronous Receiver/Transmitter)

## 특징
- **비동기(asynchronous)** 직렬 통신: 별도의 클럭 신호 없이 송신/수신 측이 동일한 **baud rate**를 미리 약속해서 동기화
- 1:1 통신, 전이중(Full-duplex) — TX/RX 라인이 분리되어 있음

## 프레임 구조
```
 Idle ─ Start ─ D0 D1 D2 D3 D4 D5 D6 D7 ─ [Parity] ─ Stop ─ Idle
        (0)                                          (1)
```
- Idle: 라인이 High(1) 유지
- Start bit: Low(0)로 전이 → 수신 측이 프레임 시작을 감지
- Data bits: 보통 8비트, LSB부터 전송
- Parity bit(선택): 에러 검출용
- Stop bit: High(1)로 복귀

## Baud Rate
- 초당 전송되는 비트 수 (bps)
- 송/수신 클럭이 없으므로, 각 비트를 **baud rate 주기의 중앙 지점**에서 샘플링해야 노이즈에 안전
- 클럭 분주(clock divider)로 baud rate 타이밍 생성: `baud_tick = clk_freq / baud_rate`

## RX 설계 핵심
1. Idle 상태에서 라인이 1→0으로 떨어지는 순간(Start bit) 감지
2. Start bit 중앙에서 다시 한 번 확인(노이즈로 인한 오탐 방지)
3. 이후 baud rate 주기마다 8번 샘플링해 8비트 데이터 수집
4. Stop bit 확인 후 수신 완료 플래그 발생

## TX 설계 핵심
1. 전송할 8비트 데이터를 병렬로 로드
2. Start bit(0) → 8bit 데이터(LSB first) → Stop bit(1) 순서로 직렬 출력
3. 각 비트를 baud rate 주기만큼 유지

## 본 프로젝트 연관
- `05_FINAL_ALU`의 Data Flow(`UART RX → Command Parser → ALU → Encoder → UART TX`)의 입출력 계층
- 세부 명령어 파싱 로직은 [[uart_calculator]] 참고
