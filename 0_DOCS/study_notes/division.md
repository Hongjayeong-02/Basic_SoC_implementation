# Division — Unsigned / Signed

## Restoring Division (기본 알고리즘)
1. 나머지 레지스터(remainder)를 0으로 초기화
2. 1비트씩 좌시프트하며 피제수를 넣음
3. remainder에서 divisor를 뺀 결과가 음수면 원상복구(restore) + 몫 비트 0
4. 결과가 양수면 그대로 유지 + 몫 비트 1
5. N번 반복

## Non-Restoring Division
- 매 스텝마다 무조건 뺄셈 또는 덧셈을 수행 (restore 단계를 생략)
- 이전 스텝의 부호에 따라 다음 스텝에서 더할지 뺄지 결정 → 평균적으로 더 빠름

## Unsigned Division (DIVU)
- 부호 처리 없이 그대로 몫/나머지 계산

## Signed Division (DIVS)
- 부호를 먼저 분리해서 절댓값끼리 unsigned 나눗셈 수행 후, 부호 규칙에 따라 결과 부호 복원
- 몫의 부호 = 두 피연산자 부호가 다르면 음수
- 나머지의 부호 = 피제수(dividend)의 부호를 따름 (Verilog `%` 연산자 규칙과 동일)

```verilog
// 개념적 예시
wire sign_q = a[7] ^ b[7];         // 몫 부호
wire [7:0] abs_a = a[7] ? -a : a;  // 절댓값
wire [7:0] abs_b = b[7] ? -b : b;
```

## 예외 처리
- **0으로 나누기(divide by zero)**: 별도 플래그(예: `o_div_by_zero`)로 처리하는 것을 권장
- 최소 음수(예: 8비트에서 -128) ÷ -1 인 경우 오버플로우 가능성 고려

## 본 프로젝트 연관
- `04_ALU_MUL_DIV`에서 DIVU/DIVS 모두 구현
- `05_FINAL_ALU`의 Supported Operations에 DIVU, DIVS로 반영됨 ([[uart_calculator]] 참고)
