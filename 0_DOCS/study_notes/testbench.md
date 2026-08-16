# Testbench 작성 규칙 (본 프로젝트 표준)

## 파일 분리
- RTL(`module.v`)과 TB(`tb_module.v`)는 항상 별도 파일로 분리

## Clock 생성
```verilog
reg clk = 0;
always #5 clk = ~clk;   // 10ns 주기, forever 대신 always 블록도 동일 효과
```
- 표준 표현: `forever #5 clk = ~clk;` (initial 블록 내부)

## Reset 시퀀스
```verilog
initial begin
    rst_n = 0;
    #20 rst_n = 1;      // 일정 시간(예: 20ns) 후 리셋 해제
end
```

## 검증(Verification) 매크로
```verilog
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_top);
end

always @(posedge clk) begin
    $monitor("time=%0t state=%d o_data=%h", $time, dut.state, o_data);
end
```
- `$dumpfile` / `$dumpvars`: 파형(VCD) 덤프 → SimVision에서 확인
- `$monitor`: 신호 변화 시마다 콘솔에 자동 출력

## 자가 검증(Self-checking) 패턴
```verilog
task check(input [7:0] expected, input [7:0] actual);
    if (expected !== actual)
        $display("FAIL: expected=%h actual=%h at time=%0t", expected, actual, $time);
    else
        $display("PASS: %h", actual);
endtask
```
- 사람이 파형을 일일이 보지 않아도 PASS/FAIL이 자동으로 콘솔에 출력되도록 구성

## 시뮬레이션 종료
```verilog
initial begin
    #1000;
    $finish;
end
```

## 본 프로젝트 연관
- 모든 RTL 마일스톤(01~05)에 대해 이 패턴을 그대로 재사용
- `05_FINAL_ALU`는 UART 프로토콜 특성상 타임아웃(`#1000` 등) 값을 baud rate에 맞게 충분히 크게 설정해야 함
