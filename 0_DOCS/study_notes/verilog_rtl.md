# Verilog RTL 코딩 컨벤션 (본 프로젝트 표준)

## 모듈 작성 순서
```
module 선언
    ↓
포트 리스트
    ↓
input / output 선언
    ↓
reg 선언
    ↓
parameter
    ↓
submodule 인스턴스
    ↓
always 블록
```

## 핵심 규칙 요약
| 항목 | 규칙 |
|:--|:--|
| Clock | `posedge clk` |
| Reset | `rst_n`, Active-Low |
| Reset 방식 | `negedge rst_n` 비동기 |
| 순차회로 | `always @(posedge clk or negedge rst_n)` + `<=` |
| 조합회로 | `always @(*)` + `=` |
| Input 이름 | `i_` 접두사 |
| Output 이름 | `o_` 접두사 |
| 모듈 구조 | Top + Submodule |

## 예시 스켈레톤
```verilog
module alu #(
    parameter WIDTH = 8
)(
    input                  clk,
    input                  rst_n,
    input  [WIDTH-1:0]     i_a,
    input  [WIDTH-1:0]     i_b,
    input  [1:0]           i_op,
    output reg [WIDTH-1:0] o_result
);

    // submodule 인스턴스
    adder_cla #(.WIDTH(WIDTH)) u_adder (
        .i_a   (i_a),
        .i_b   (i_b),
        .o_sum (w_sum)
    );

    // 조합 로직
    always @(*) begin
        case (i_op)
            2'b00: o_result = w_sum;
            default: o_result = {WIDTH{1'b0}};
        endcase
    end

endmodule
```

## Top + Submodule 구조를 쓰는 이유
- 기능 단위(adder, mux, fsm 등)를 독립적으로 검증 가능 → 단위 테스트가 쉬움
- Top 모듈은 배선(interconnect)과 상위 제어 로직만 담당해 가독성 유지
- 이후 합성 시 서브모듈 단위로 타이밍 분석/최적화가 용이

## 네이밍이 실무에서 중요한 이유
- `i_`/`o_` 접두사만으로 포트 방향이 코드 어디서든 명확 → 리뷰/디버깅 속도 향상
- 대규모 SoC에서는 신호 수가 수천 개가 되므로, 일관된 네이밍 컨벤션이 없으면 유지보수가 불가능해짐

## 본 프로젝트 연관
- 01~05 모든 RTL 마일스톤이 이 컨벤션을 동일하게 따름 (README의 Tech Stack & Conventions 표와 1:1 대응)
