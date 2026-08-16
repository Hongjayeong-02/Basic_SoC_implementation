# Digital Logic Basics

## 조합회로 (Combinational Logic)
- 출력이 **현재 입력에만** 의존, 메모리(상태)가 없음
- Verilog에서는 `always @(*)` + 블로킹 대입(`=`) 사용
- 대표 예: MUX, DEMUX, 인코더/디코더, ALU의 연산 로직

```verilog
always @(*) begin
    case (sel)
        2'b00: o_data = i_a;
        2'b01: o_data = i_b;
        default: o_data = 8'b0;
    endcase
end
```

## 순차회로 (Sequential Logic)
- 출력이 **현재 입력 + 이전 상태**에 의존 (클럭에 동기화된 상태 저장)
- Verilog에서는 `always @(posedge clk or negedge rst_n)` + 논블로킹 대입(`<=`) 사용
- 대표 예: 레지스터, 카운터, FSM, FIFO

```verilog
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        o_data <= 8'b0;
    else
        o_data <= i_data;
end
```

## 블로킹(`=`) vs 논블로킹(`<=`)
| 구분 | 블로킹 `=` | 논블로킹 `<=` |
|:--|:--|:--|
| 실행 방식 | 순서대로 즉시 대입 | 모든 RHS 평가 후 동시에 대입 |
| 사용처 | 조합회로 (`always @(*)`) | 순차회로 (`always @(posedge clk)`) |
| 실수 시 문제 | 순차회로에 쓰면 레이스 컨디션 발생 가능 | 조합회로에 쓰면 시뮬레이션-합성 불일치 가능 |

## Reset 정책 (본 프로젝트 컨벤션)
- `rst_n`: **Active-Low**, **비동기(asynchronous)** 리셋
- `always @(posedge clk or negedge rst_n)` 형태로 감지 리스트에 반드시 포함
- 리셋 시 모든 레지스터를 알려진 초기값(보통 0)으로 강제

## 왜 이 컨벤션을 쓰는가
- `posedge clk` 단일 엣지 트리거 → 타이밍 분석이 단순해짐
- 비동기 `rst_n`은 전원 인가 직후처럼 클럭이 아직 안정되지 않은 상황에서도 즉시 초기화 가능
- `i_`/`o_` 접두사는 포트 방향을 이름만으로 즉시 구분 가능하게 함
