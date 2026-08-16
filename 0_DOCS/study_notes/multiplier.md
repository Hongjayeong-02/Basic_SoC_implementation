# Multiplier

## Shift-and-Add 방식
- 초등 필산 곱셈과 동일한 원리: 승수(multiplier)의 각 비트를 확인하며 피승수(multiplicand)를 시프트하고 누적
- N비트 × N비트 → 결과는 최대 2N비트

```verilog
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        product <= 0;
        count   <= 0;
    end else if (start) begin
        if (multiplier[0])
            product <= product + (multiplicand << count);
        multiplier <= multiplier >> 1;
        count <= count + 1;
    end
end
```
- 순차(sequential) 방식: N클럭 소요, 면적 작음
- 병렬(combinational array) 방식: 1클럭에 완료 가능하지만 게이트 수가 큼 (Array Multiplier)

## Signed 곱셈 시 주의점
- 피연산자를 signed로 선언하지 않으면 자동으로 unsigned 곱셈이 수행됨
- Booth's Algorithm: signed 곱셈을 더 적은 덧셈 횟수로 처리하는 최적화 기법 (음수/양수 전환 구간을 감지해 스킵)

## 본 프로젝트 연관
- `04_ALU_MUL_DIV`에서 MUL 연산 구현
- Verification 시 최대값(예: 0xFF × 0xFF) 등 경계 케이스를 반드시 확인
