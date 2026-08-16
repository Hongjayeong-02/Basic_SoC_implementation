# Adder — Half Adder → Full Adder → RCA

## Half Adder
- 입력 2개(A, B), 출력 2개(Sum, Carry)
- 자리올림 입력(Cin)을 받지 못함 → 최하위 비트에만 사용 가능

```verilog
assign o_sum   = i_a ^ i_b;
assign o_carry = i_a & i_b;
```

## Full Adder
- 입력 3개(A, B, Cin), 출력 2개(Sum, Cout)
- Half Adder 2개 + OR 게이트 1개로 구성 가능

```verilog
assign o_sum  = i_a ^ i_b ^ i_cin;
assign o_cout = (i_a & i_b) | (i_cin & (i_a ^ i_b));
```

## Ripple Carry Adder (RCA)
- Full Adder를 N개 직렬로 연결, 각 자리의 Cout이 다음 자리의 Cin으로 전파
- 구조는 단순하지만 **자리올림이 LSB→MSB로 순차 전파**되므로 비트 폭이 커질수록 지연시간(critical path)이 선형으로 증가

```
Cin ─▶[FA0]─▶[FA1]─▶[FA2]─▶ ... ─▶[FA7]─▶ Cout
       │       │       │              │
      S0      S1      S2            S7
```

## RCA의 한계
- N비트 RCA의 최악 지연 ≈ N × (1 Full Adder 지연)
- 비트 폭이 넓어질수록(예: 32비트, 64비트) 전체 연산 속도의 병목이 됨
- → 이 문제를 해결하기 위한 다음 단계가 [[cla]] (Carry Lookahead Adder)

## 본 프로젝트 연관
- `02_RCA_to_CLA` 마일스톤에서 RCA를 먼저 구현하고 CLA로 구조를 개선
