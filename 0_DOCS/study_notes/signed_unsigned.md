# Signed / Unsigned Representation

## Unsigned
- 모든 비트가 크기(magnitude)를 표현
- 8비트 unsigned 범위: `0 ~ 255`

## Signed — 2의 보수 (Two's Complement)
- MSB가 부호 비트 (0 = 양수, 1 = 음수)
- 8비트 signed 범위: `-128 ~ 127`
- 음수 변환: 비트 반전 후 +1

```
+5  = 0000_0101
-5  = 1111_1011   (0000_0101 반전 → 1111_1010, +1 → 1111_1011)
```

## 왜 2의 보수를 쓰는가
- 덧셈/뺄셈 회로를 부호와 무관하게 **동일한 가산기 하드웨어**로 처리 가능
- `A - B = A + (~B + 1)` → 별도의 뺄셈기 불필요, 가산기 + 인버터로 구현

## Sign Extension
- 비트 폭을 늘릴 때 MSB(부호 비트)를 그대로 복제해서 채움

```verilog
wire signed [15:0] o_ext = {{8{i_data[7]}}, i_data}; // 8bit -> 16bit
```

## Verilog에서 signed 선언
```verilog
wire signed [7:0] a, b;
wire signed [8:0] sum = a + b; // 부호 유지한 채 연산
```
- `signed` 선언을 빠뜨리면 비교/시프트 연산이 unsigned로 처리되어 의도와 다른 결과가 나올 수 있음
- 곱셈기에서는 signed × signed → 결과 비트폭 = 두 피연산자 비트폭의 합

## 본 프로젝트 연관
- `04_ALU_MUL_DIV`: 곱셈/나눗셈에서 signed(DIVS)와 unsigned(DIVU) 연산을 분리 구현
- ALU의 SUB 연산은 내부적으로 2의 보수 덧셈으로 구현
