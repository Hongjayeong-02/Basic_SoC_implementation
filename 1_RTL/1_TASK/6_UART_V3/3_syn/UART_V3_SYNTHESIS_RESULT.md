# UART V3 Synthesis Result

## 1. Overview

UART V3 Peripheral IP에 대해 **Cadence Genus 기반 RTL Synthesis**를 수행하였다.

기능 검증 이후 실제 합성 환경에서 RTL hierarchy와 dependency를 확인하고, SDC constraint를 적용하여 timing 및 area를 분석하였다.

### Design Environment

| Item | Value |
|---|---|
| Design | UART V3 Peripheral IP |
| Top Module | `uart_apb` |
| Language | Verilog HDL |
| Synthesis Tool | Cadence Genus |
| Target Clock | 50 MHz |
| Clock Period | 20.0 ns |
| Clock Port | `clk` |
| Reset | `rst_n` |
| Reset Type | Asynchronous Active-Low |
| Library Corner | `slow_vdd1v0_basicCells.lib` |
| UART RX | `i_uartRx` |
| RX Synchronizer | 2-FF Synchronizer |

---

## 2. RTL Hierarchy

합성에 사용한 RTL은 총 **9개 파일**이다.

```text
uart_baud_gen.v
uart_fifo.v
uart_tx.v
uart_tx_fifo.v
uart_rx.v
uart_rx_fifo.v
uart_core.v
uart_irq.v
uart_apb.v
```

Top module은 `uart_apb`이며 내부에 UART Core, TX/RX, FIFO, baud generator, interrupt logic이 연결된다.

---

## 3. Synthesis Flow

전체 합성 흐름은 다음과 같다.

```text
RTL File Check
      ↓
Read Library
      ↓
Read HDL
      ↓
Elaboration
      ↓
check_design
      ↓
SDC Constraint
      ↓
syn_generic
      ↓
syn_map
      ↓
syn_opt
      ↓
Timing / Area / Power Report
      ↓
Netlist / SDC Output
```

합성 과정은 Tcl script를 사용하여 자동화하였다.

주요 자동화 항목은 다음과 같다.

- RTL file 존재 여부 확인
- Library path 확인
- Top-level port 검증
- Clock constraint 생성
- Input / Output delay 적용
- Async reset false path 설정
- UART RX asynchronous input false path 설정
- `check_design` report 생성
- Timing / Area / Power report 생성
- Gate-level netlist 및 synthesized SDC 출력

---

## 4. SDC Constraint

### Clock

```tcl
create_clock \
    -name PCLK \
    -period 20.0 \
    [get_ports clk]
```

50 MHz PCLK를 기준으로 합성을 수행하였다.

```text
Frequency = 50 MHz
Period    = 20 ns
```

### Clock Uncertainty

```tcl
set_clock_uncertainty 0.2 [get_clocks PCLK]
```

Clock jitter 및 timing margin을 고려하기 위해 0.2 ns uncertainty를 적용하였다.

### I/O Delay

```text
Input Delay  = 2.0 ns
Output Delay = 2.0 ns
```

APB synchronous input과 output에 각각 I/O delay를 적용하였다.

### Asynchronous Paths

`rst_n`은 asynchronous reset이므로 timing analysis 대상에서 제외하였다.

또한 UART RX 입력 `i_uartRx`는 내부의 **2-FF synchronizer**를 통해 clock domain에 동기화되므로 input pin에서 시작하는 asynchronous path에 false path를 적용하였다.

---

## 5. Debugging – Missing RTL Dependency

최초 synthesis 수행 시 `check_design` 결과 다음 unresolved reference가 발생하였다.

```text
hinst:uart_apb/uut_uart_core/uut_tx_fifo/uut_fifo
```

초기 RTL filelist는 다음과 같았다.

```text
uart_baud_gen.v
uart_tx.v
uart_tx_fifo.v
uart_rx.v
uart_rx_fifo.v
uart_core.v
uart_irq.v
uart_apb.v
```

`uart_tx_fifo.v` 내부를 확인한 결과 다음과 같이 `uart_fifo` module을 instantiate하고 있었다.

```verilog
uart_fifo #(
    .FIFO_DEPTH(FIFO_DEPTH)
) uut_fifo (
    ...
);
```

그러나 `uart_fifo.v`가 synthesis filelist에서 누락되어 있었다.

### Root Cause

```text
uart_tx_fifo.v
     ↓ instantiate
uart_fifo
     ↓
uart_fifo.v missing from synthesis filelist
```

따라서 Genus가 `uut_fifo` hierarchy를 resolve하지 못하였다.

### Fix

RTL filelist에 `uart_fifo.v`를 추가하였다.

```text
uart_baud_gen.v
uart_fifo.v
uart_tx.v
uart_tx_fifo.v
uart_rx.v
uart_rx_fifo.v
uart_core.v
uart_irq.v
uart_apb.v
```

수정 후 재합성을 수행하였다.

---

## 6. check_design Result

Filelist 수정 후 `check_design` 결과는 다음과 같다.

| Check | Result |
|---|---:|
| Unresolved References | **0** |
| Empty Modules | **0** |
| Undriven Ports | **0** |
| Undriven Leaf Pins | **0** |
| Multidriven Ports | **0** |
| Multidriven Leaf Pins | **0** |
| Logical Instances | **922** |

최초 불완전한 hierarchy에서는 unresolved reference와 함께 다수의 multidriven leaf pin이 보고되었으나, `uart_fifo.v` dependency를 추가한 뒤 모두 제거되었다.

이를 통해 실제 RTL multi-driver 문제가 아니라 **불완전한 synthesis hierarchy에서 파생된 check result**임을 확인하였다.

---

## 7. Timing Result

Genus timing report를 Tcl parser로 분석한 결과는 다음과 같다.

```text
WNS      : +14.577 ns
TNS      : 0.000 ns
VIOLATED : 0 / 1 paths
WORST EP : o_prdata[1]
RESULT   : PASS
```

### Timing Summary

| Metric | Result |
|---|---:|
| Clock Period | 20.0 ns |
| WNS | **+14.577 ns** |
| TNS | **0.000 ns** |
| Violated Path | **0** |
| Timing Result | **PASS** |

WNS가 양수이므로 현재 적용한 50 MHz constraint에 대해 setup timing requirement를 만족한다.

---

## 8. Area Result

Genus `report_area` 결과는 다음과 같다.

```text
TOTAL AREA : 3360.150
CELL COUNT : 922
TOP        : uart_apb
```

### Area Summary

| Metric | Result |
|---|---:|
| Total Area | **3360.150** |
| Cell Count | **922** |
| Top Module | `uart_apb` |

초기 불완전한 synthesis 결과에서는 다음 값이 측정되었다.

```text
Area       : 2590.992
Cell Count : 740
```

`uart_fifo.v`를 추가한 이후 FIFO logic이 정상적으로 synthesis hierarchy에 포함되면서 최종 결과가 다음과 같이 증가하였다.

```text
2590.992 → 3360.150
740 cells → 922 cells
```

따라서 최종 area 및 cell count는 **9개 RTL 전체가 포함된 재합성 결과**를 기준으로 한다.

---

## 9. Tcl Report Automation

Genus에서 생성된 report를 직접 확인하는 것뿐 아니라 Tcl parser를 구현하여 timing 및 area 결과를 자동으로 분석하였다.

### Timing Parser

```bash
tclsh parse_timing_report.tcl reports/uart_timing.rpt
```

분석 항목:

- WNS
- TNS
- Violated Path Count
- Worst Endpoint
- PASS / FAIL

### Area Parser

```bash
tclsh parse_area_report.tcl reports/uart_area.rpt
```

분석 항목:

- Total Area
- Cell Count
- Hierarchy Area
- Area Limit 비교

이를 통해 다음과 같은 자동화 flow를 구성하였다.

```text
RTL
 ↓
Genus Synthesis
 ↓
Report Generation
 ↓
Tcl Report Parser
 ↓
PASS / FAIL Decision
```

---

## 10. Final Result

UART V3에 대해 RTL 기능 구현 이후 실제 ASIC synthesis flow를 적용하여 다음을 확인하였다.

```text
Top Module            : uart_apb
RTL Files             : 9
Clock                 : 50 MHz
Corner                : slow_vdd1v0
Logical Cell Count    : 922
Total Area            : 3360.150
WNS                   : +14.577 ns
TNS                   : 0.000 ns
Timing Violation      : 0
Unresolved Reference  : 0
Multidriven Pin       : 0
Timing Result         : PASS
```

이번 synthesis 과정에서 단순히 RTL을 합성하는 데 그치지 않고,

1. hierarchy dependency 확인
2. unresolved reference 분석
3. synthesis filelist 수정
4. design integrity 재검증
5. timing / area 분석
6. Tcl 기반 report parsing 자동화

까지 수행하였다.

이를 통해 **UART Peripheral IP RTL Design → Functional Verification → Synthesis → Timing/Area Analysis**로 이어지는 ASIC front-end design flow를 경험하였다.
