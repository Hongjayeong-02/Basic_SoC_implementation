# FSM (Finite State Machine)

## Moore vs Mealy
| 구분 | Moore | Mealy |
|:--|:--|:--|
| 출력 결정 요인 | 현재 상태만 | 현재 상태 + 현재 입력 |
| 출력 타이밍 | 클럭 엣지 이후 안정적 | 입력 변화에 즉시 반응 (더 빠르지만 글리치 위험) |
| 설계 난이도 | 상대적으로 단순 | 상태 수를 줄일 수 있음 |

본 프로젝트는 UART 기반 제어 로직에서 주로 **Moore 방식**을 사용 (출력이 안정적이어야 하는 프로토콜 특성상 유리).

## 표준 FSM 코딩 스타일 (3-always 또는 2-always 블록)
```verilog
// 상태 레지스터 (순차)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= S_IDLE;
    else        state <= next_state;
end

// 다음 상태 로직 (조합)
always @(*) begin
    case (state)
        S_IDLE: next_state = i_start ? S_RUN : S_IDLE;
        S_RUN:  next_state = i_done  ? S_DONE : S_RUN;
        S_DONE: next_state = S_IDLE;
        default: next_state = S_IDLE;
    endcase
end

// 출력 로직 (Moore: 조합, 상태에만 의존)
always @(*) begin
    o_busy = (state == S_RUN);
end
```

## 상태 인코딩
- **Binary encoding**: 상태 수만큼 최소 비트 사용, 면적 효율적
- **One-hot encoding**: 상태 수만큼 비트 사용, 디코딩 로직이 단순해져 고속 설계에 유리 (FPGA에서 특히 선호)

## 본 프로젝트 연관
- `05_FINAL_ALU`의 Command Parser가 FSM으로 구현됨 (UART RX → 파싱 → ALU 실행 → 결과 인코딩 → TX 전송의 상태 전이)
