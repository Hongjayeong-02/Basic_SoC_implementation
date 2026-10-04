# UART V3 Backend Freeze

| 항목 | 내용 |
|---|---|
| Design | UART Peripheral IP (APB3 slave) — V3 |
| 문서 목적 | Functional / Architecture / Synthesis 결정사항 확정 (Genus 합성 진입 전 Freeze) |
| 작성일 | 2026-10-04 |
| 참조 | Notion `강의노트 > Linux > UART 설계 Spec` (`UART_SPEC.pdf`, `UART_Peripheral_IP_RTL_설계명세서.pdf`) |
| 상태 | STEP 1~2 확정 / STEP 3 constraint 일부 TBD |

---

## Freeze 핵심 값

```text
PCLK              = 50 MHz (period 20.0 ns)
BAUD_DIV reset    = 325
                     Baud = PCLK / (16 × (BAUD_DIV + 1))
                     ≈ 9585.9 bps, error ≈ -0.147%

TX FIFO default   = 8
RX FIFO default   = 8

STRICT_APB_ERR    = 0

Async UART RX     = i_uartRx
                     2-FF synchronizer 확인 완료
                     → normal synchronous timing에서 false path 적용

Async rst_n       = normal data-path timing에서 false path
                     recovery/removal은 signoff STA에서 별도 검토

I/O delay         = TBD
Output load       = TBD
Clock uncertainty = TBD
Clock transition  = TBD
```

---

# 0. Freeze 순서 요약

```text
STEP 1  Functional Freeze     ✅ Final regression ALL PASS
STEP 2  Architecture Freeze   ✅ 확정
STEP 3  Synthesis Freeze      🔶 Constraint 값 일부 TBD
STEP 4  Genus Synthesis       ⏳
STEP 5  Check                 ⏳ timing / area / power / warnings
```

> 원칙: STEP 2 이후 RTL 기능 변경 금지.  
> RTL 변경이 필요한 경우 본 문서 개정 → regression 재실행 → 재-Freeze 한다.

---

# 1. Functional Freeze — STEP 1

## 1.1 Final Regression

UART V3 final regression 결과:

```text
UART V3 FINAL REGRESSION: ALL PASS
```

검증 완료 항목:

- [x] Reset
- [x] 8N1 loopback
- [x] RX IRQ
- [x] 7-bit / Odd parity / 2-stop
- [x] TX_EN / RX_EN gating
- [x] RX parity metadata
- [x] RX frame-error metadata
- [x] Error sticky status
- [x] RW1C clear
- [x] RX FIFO overflow
- [x] Overflow sticky status
- [x] Overflow IRQ
- [x] Overflow APB readback
- [x] Old RX FIFO data preservation
- [x] Mid-traffic reset
- [x] `BAUD RESET = 325`

---

## 1.2 RX Overflow 최종 결과

V3 주요 blocker였던 RX overflow 동작을 최종 검증함.

```text
RX FIFO depth = 8
      ↓
8 bytes stored
      ↓
9th byte arrives
      ↓
New byte DROP
      ↓
Existing 8 bytes preserved
      ↓
overflow event pulse
      ↓
IRQ_STATUS[4] sticky set
      ↓
STATUS[8] set
      ↓
IRQ assert
      ↓
RW1C
      ↓
sticky / IRQ clear
```

최종 결과:

```text
NEW BYTE DROPPED             PASS
RX OVERFLOW EVENT PULSE      PASS
OVERFLOW STICKY INTERNAL     PASS
OVERFLOW IRQ STATUS          PASS
OVERFLOW IRQ                 PASS
STATUS OVERFLOW              PASS
ORIGINAL 8 BYTES PRESERVED   PASS
OVERFLOW CLEAR               PASS
```

---

## 1.3 FIFO Depth 이력

과거 V2 단계에서 16-depth FIFO 실험 이력이 존재하나, 현재 UART V3의 default 및 regression 기준은 **8-depth**이다.

```text
V2 historical configuration : depth 16
V3 frozen configuration      : depth 8
```

Final regression이 8-depth 기준으로 완료되었으므로 Backend Freeze 기준도 8로 확정한다.

---

# 2. Architecture Freeze — STEP 2

## 2.1 FIFO Configuration

| 항목 | 결정 |
|---|---|
| TX FIFO default | 8 |
| RX FIFO default | 8 |
| Parameterizable | 유지 |
| Verified configuration | TX=8 / RX=8 |

RTL:

```verilog
parameter TX_FIFO_DEPTH = 8,
parameter RX_FIFO_DEPTH = 8
```

정책:

```text
Default configuration = 8 entries
Parameterization       = retained
Validated configuration = TX 8 / RX 8
```

FIFO depth 변경 시 새로운 regression을 수행한다.

16 / 32-depth parameter 검증은 optional extension으로 남기며 현재 Backend Freeze 범위에는 포함하지 않는다.

---

## 2.2 APB Error Policy

RTL parameter:

```verilog
parameter STRICT_APB_ERR = 1'b0
```

### Default mode

```text
STRICT_APB_ERR = 0
```

permissive APB policy를 사용한다.

Illegal / unsupported APB access 발생 시 기본적으로 기능 동작은 안전하게 무시하거나 정의된 기본값을 반환하며 `PSLVERR`는 assert하지 않는다.

예:

```text
invalid register access
TX FIFO full 상태에서 TX_DATA write
RX FIFO empty 상태에서 RX_DATA read
unsupported access direction
```

### Strict mode

```text
STRICT_APB_ERR = 1
```

RTL에서 구현된 illegal-access case에 대해 `PSLVERR`를 assert한다.

합성 및 Backend Freeze 기준:

```text
STRICT_APB_ERR = 0
```

---

## 2.3 APB PREADY Policy

현재 UART APB는 완전한 always-ready slave가 아니다.

### 일반 register access

```text
PREADY = 1
```

즉 zero wait-state.

### RX_DATA valid read

RX FIFO output이 synchronous하게 갱신되므로 RX_DATA read에서는 1-cycle wait가 발생할 수 있다.

```text
APB RX_DATA read
      ↓
RX FIFO read enable
      ↓
PREADY = 0
      ↓
FIFO registered output update
      ↓
next APB cycle
      ↓
PREADY = 1
PRDATA valid
```

따라서 Freeze 정의:

```text
Normal register access : zero wait-state
RX_DATA valid read     : 1-cycle wait-state
```

---

## 2.4 Configuration Change Policy

대상:

```text
BAUD_DIV
DATA7
PARITY_MODE
STOP2
```

정책:

```text
Configuration register writes are allowed,
but software must modify communication settings only when TX/RX are idle.
```

권장 조건:

```text
TX_BUSY = 0
AND
RX_BUSY = 0
```

추가 권장:

```text
TX FIFO EMPTY
```

Frame 진행 중 configuration 변경은 검증 범위 밖이며 동작은 undefined로 정의한다.

RTL에 별도의 configuration-write interlock은 추가하지 않는다.

---

## 2.5 Enable Policy

대상:

```text
UART_EN
TX_EN
RX_EN
```

| 항목 | 정의 |
|---|---|
| Disable 시 | 신규 operation 시작 차단 |
| TX/RX gating | regression 검증 완료 |
| In-flight frame disable | implementation-defined |
| Software rule | TX/RX idle 상태에서 disable 수행 |

---

# 3. Synthesis Freeze — STEP 3

## 3.1 Synthesis Top

```text
TOP = uart_apb
```

UART IP boundary는 다음을 포함한다.

```text
uart_apb
├── APB3 register interface
├── uart_core
│   ├── uart_baud_gen
│   ├── uart_tx_fifo
│   │   └── uart_tx
│   └── uart_rx_fifo
│       └── uart_rx
└── uart_irq
```

외부 interface:

```text
PCLK / Reset
APB3
UART RX
UART TX
IRQ
```

---

## 3.2 Active RTL Hierarchy

현재 GitHub V3 RTL 기준 active synthesis hierarchy:

```text
uart_apb
├── uart_core
│   ├── uart_baud_gen
│   ├── uart_tx_fifo
│   │   └── uart_tx
│   └── uart_rx_fifo
│       └── uart_rx
└── uart_irq
```

따라서 hierarchy / file-list Open Item은 완료 처리한다.

---

## 3.3 Synthesis File List

`filelist_syn.f`

```text
./1_rtl/uart_baud_gen.v
./1_rtl/uart_tx.v
./1_rtl/uart_tx_fifo.v
./1_rtl/uart_rx.v
./1_rtl/uart_rx_fifo.v
./1_rtl/uart_core.v
./1_rtl/uart_irq.v
./1_rtl/uart_apb.v
```

의존성 순서 기준으로 정리한다.

### Synthesis 제외

```text
uart_fifo.v
uart_loopback.v
uart_v2_top*.v
*_s.v
tb_*.v
```

위 파일들은 현재 `uart_apb` active synthesis hierarchy에 포함되지 않는다.

---

## 3.4 Synthesis 사전 점검

Genus `check_design`에서 아래 항목을 확인한다.

- [ ] unresolved reference = 0
- [ ] latch unintended inference = 0
- [ ] multiple driver = 0
- [ ] width mismatch = 0
- [ ] undriven critical signal = 0
- [ ] unmapped module = 0
- [ ] simulation-only construct 미포함

RTL 내부에 아래 simulation-only construct가 존재할 경우 제거하거나 synthesis guard를 사용한다.

```text
$display
$monitor
$dumpfile
$dumpvars
initial
```

---

# 4. Clock / Baud Freeze

## 4.1 PCLK

```text
Clock name = PCLK
Frequency  = 50 MHz
Period     = 20.0 ns
```

SDC:

```tcl
create_clock \
    -name PCLK \
    -period 20.0 \
    [get_ports clk]
```

---

## 4.2 Baud Generator

UART baud tick은 새로운 clock domain이 아니다.

`uart_baud_gen`의 `o_tick16`은 PCLK domain에서 생성되는 **1-cycle clock-enable pulse**이다.

따라서:

```text
create_generated_clock
```

은 사용하지 않는다.

전체 UART sequential logic은 동일한 `clk` domain에서 동작한다.

---

## 4.3 BAUD_DIV

RTL 공식:

```text
Baud = PCLK / (16 × (BAUD_DIV + 1))
```

비교:

| PCLK | BAUD_DIV | Baud | Error vs 9600 |
|---:|---:|---:|---:|
| 48 MHz | 312 | 9584.7 | -0.16% |
| 50 MHz | 312 | 9984.0 | +4.00% |
| **50 MHz** | **325** | **9585.9** | **-0.147%** |
| 50 MHz | 326 | 9556.6 | -0.45% |

Freeze:

```text
PCLK           = 50 MHz
BAUD_DIV reset = 325
```

현재 Final Regression에서도:

```text
BAUD RESET = 325 PASS
```

했으므로 reset value 추가 변경은 하지 않는다.

노션의 `312` 기록은 48 MHz 기반 이전 설계 이력으로만 유지한다.

---

# 5. Async UART RX

## 5.1 2-FF Synchronizer

`uart_rx.v`에 다음 synchronizer가 존재한다.

```verilog
reg r_rxMeta;
reg r_rxSync;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        r_rxMeta <= 1'b1;
        r_rxSync <= 1'b1;
    end else begin
        r_rxMeta <= i_uartRx;
        r_rxSync <= r_rxMeta;
    end
end
```

구조:

```text
i_uartRx
   ↓
r_rxMeta
   ↓
r_rxSync
   ↓
RX FSM
```

따라서 외부 UART RX는 asynchronous input으로 정의한다.

---

## 5.2 UART RX Timing Policy

`i_uartRx`는 PCLK synchronous input이 아니므로 일반 APB input과 동일한 `set_input_delay`를 적용하지 않는다.

Initial synthesis SDC:

```tcl
set_false_path -from [get_ports i_uartRx]
```

즉 asynchronous input → synchronizer path를 normal synchronous timing analysis에서 제외한다.

---

# 6. Reset Timing Policy

`rst_n`은 asynchronous active-low reset이다.

Initial synthesis에서는 normal synchronous data-path timing에서 제외한다.

```tcl
set_false_path -from [get_ports rst_n]
```

다만 이는 reset timing 검증 자체를 하지 않는다는 의미가 아니다.

Signoff STA 단계에서는 별도로:

```text
recovery
removal
reset release methodology
```

를 검토해야 한다.

따라서 Freeze 정책:

```text
Initial synthesis :
rst_n false path for normal data timing

Signoff STA :
recovery / removal separately reviewed
```

---

# 7. UART APB Top Ports

`uart_apb` 실제 top-level port:

```text
clk
rst_n

i_psel
i_penable
i_pwrite
i_paddr[7:0]
i_pwdata[31:0]

o_prdata[31:0]
o_pready
o_pslverr

i_uartRx
o_uartTx

o_irq
```

SDC에는 반드시 위 실제 RTL 이름을 사용한다.

---

# 8. SDC Initial Draft

파일명:

```text
uart_apb.sdc
```

초안:

```tcl
# ============================================================
# UART V3 - uart_apb.sdc
# Initial Genus synthesis constraint
# ============================================================


# ------------------------------------------------------------
# Clock
# ------------------------------------------------------------

create_clock \
    -name PCLK \
    -period 20.0 \
    [get_ports clk]


# Provisional values
set_clock_uncertainty \
    0.2 \
    [get_clocks PCLK]

set_clock_transition \
    0.1 \
    [get_clocks PCLK]


# ------------------------------------------------------------
# Asynchronous Reset
# ------------------------------------------------------------

# Exclude asynchronous reset from normal synchronous data-path
# timing.
#
# Recovery/removal treatment must be reviewed separately
# for signoff STA.

set_false_path \
    -from [get_ports rst_n]


# ------------------------------------------------------------
# Asynchronous UART RX
# ------------------------------------------------------------

# uart_rx contains:
# i_uartRx -> r_rxMeta -> r_rxSync
#
# External UART RX is asynchronous to PCLK.

set_false_path \
    -from [get_ports i_uartRx]


# ------------------------------------------------------------
# APB Input Interface
# ------------------------------------------------------------

set APB_INPUTS [get_ports {
    i_psel
    i_penable
    i_pwrite
    i_paddr[*]
    i_pwdata[*]
}]


# Provisional bring-up value.
# Final value TBD based on integration timing budget.

set_input_delay \
    2.0 \
    -clock PCLK \
    $APB_INPUTS


# ------------------------------------------------------------
# APB Output Interface
# ------------------------------------------------------------

set APB_OUTPUTS [get_ports {
    o_prdata[*]
    o_pready
    o_pslverr
}]


# Provisional bring-up value.
# Final value TBD based on integration timing budget.

set_output_delay \
    2.0 \
    -clock PCLK \
    $APB_OUTPUTS


# ------------------------------------------------------------
# Other Outputs
# ------------------------------------------------------------

# o_uartTx:
# UART serial output.
# Final external timing/load requirement TBD.

# o_irq:
# SoC interrupt integration requirement TBD.


# ------------------------------------------------------------
# Output Load
# ------------------------------------------------------------

# Provisional only.
# Replace with integration / board / library-based value.

set_load \
    0.01 \
    [all_outputs]


# ------------------------------------------------------------
# Input Driving Cell
# ------------------------------------------------------------

# TBD
#
# Example:
#
# set_driving_cell \
#     -lib_cell <BUFFER_CELL> \
#     $APB_INPUTS
```

---

# 9. SDC Constraint Status

| 항목 | 상태 |
|---|---|
| PCLK 50 MHz | ✅ Freeze |
| Clock period 20 ns | ✅ Freeze |
| i_uartRx asynchronous | ✅ Freeze |
| 2-FF synchronizer | ✅ 확인 |
| UART RX false path | ✅ Freeze |
| rst_n async | ✅ Freeze |
| Reset normal-path false path | ✅ Initial synthesis |
| APB port names | ✅ 확인 |
| Input delay | 🔶 TBD |
| Output delay | 🔶 TBD |
| Clock uncertainty | 🔶 TBD |
| Clock transition | 🔶 TBD |
| Output load | 🔶 TBD |
| Driving cell | 🔶 TBD |
| Recovery / removal | 🔶 Signoff item |

---

# 10. Library / Corner

## 10.1 Initial Synthesis

```text
Corner = Slow
Library = slow_vdd1v0_basicCells.lib
Technology = GPDK045
```

목적:

```text
setup-oriented synthesis
timing baseline
area baseline
power baseline
```

---

## 10.2 Future Extension

향후 필요 시:

```text
fast_vdd1v0_basicCells.lib
```

을 이용한 fast-corner 분석을 추가한다.

단, initial UART synthesis는:

```text
single corner
single mode
```

로 수행한다.

MMMC는 Innovus PnR / full STA 단계에서 확장한다.

---

# 11. Genus Synthesis Plan

파일명 예:

```text
syn_uart_apb.tcl
```

Skeleton:

```tcl
# ============================================================
# UART V3 Genus synthesis
# ============================================================


# ------------------------------------------------------------
# Path
# ------------------------------------------------------------

set RTL_PATH <RTL_PATH>
set LIB_PATH <LIB_PATH>


set_db init_hdl_search_path $RTL_PATH
set_db init_lib_search_path $LIB_PATH


# ------------------------------------------------------------
# Library
# ------------------------------------------------------------

set_db library slow_vdd1v0_basicCells.lib


# ------------------------------------------------------------
# RTL
# ------------------------------------------------------------

read_hdl -f filelist_syn.f


# ------------------------------------------------------------
# Elaborate
# ------------------------------------------------------------

elaborate uart_apb


# ------------------------------------------------------------
# Check
# ------------------------------------------------------------

check_design -unresolved


# ------------------------------------------------------------
# Constraints
# ------------------------------------------------------------

read_sdc uart_apb.sdc


# ------------------------------------------------------------
# Synthesis
# ------------------------------------------------------------

syn_generic
syn_map
syn_opt


# ------------------------------------------------------------
# Reports
# ------------------------------------------------------------

report_timing > rpt/timing.rpt
report_area   > rpt/area.rpt
report_power  > rpt/power.rpt
report_gates  > rpt/gates.rpt

check_design -all > rpt/check_design.rpt


# ------------------------------------------------------------
# Output
# ------------------------------------------------------------

write_hdl > out/uart_apb_netlist.v
write_sdc > out/uart_apb_syn.sdc
```

---

# 12. Backend Directory 제안

UART V3 folder 내부:

```text
6_UART_V3/
│
├── 0_docs/
│   └── UART_V3_BACKEND_FREEZE.md
│
├── 1_rtl/
│   ├── uart_apb.v
│   ├── uart_core.v
│   ├── uart_baud_gen.v
│   ├── uart_tx_fifo.v
│   ├── uart_tx.v
│   ├── uart_rx_fifo.v
│   ├── uart_rx.v
│   └── uart_irq.v
│
├── 2_tb/
│
├── 3_syn/
│   ├── filelist_syn.f
│   ├── uart_apb.sdc
│   ├── syn_uart_apb.tcl
│   │
│   ├── rpt/
│   └── out/
│
├── Makefile
└── run.tcl
```

Backend Freeze 문서는:

```text
0_docs/UART_V3_BACKEND_FREEZE.md
```

에 저장한다.

---

# 13. Genus Check Criteria

| 항목 | Pass 기준 |
|---|---|
| Elaborate | `uart_apb` 정상 elaborate |
| Unresolved reference | 0 |
| Unmapped cells | 0 |
| Timing | WNS ≥ 0 |
| Timing | TNS = 0 |
| Latch | unintended latch 0 |
| Multiple driver | 0 |
| Width mismatch | critical issue 0 |
| Undriven | critical issue 0 |
| Area | baseline 기록 |
| Power | baseline 기록 |
| Netlist | 생성 완료 |
| Synthesized SDC | 생성 완료 |

---

# 14. Backend Output Artifact

합성 완료 후 보존 대상:

```text
out/
├── uart_apb_netlist.v
└── uart_apb_syn.sdc

rpt/
├── timing.rpt
├── area.rpt
├── power.rpt
├── gates.rpt
└── check_design.rpt
```

향후 필요 시:

```text
SDF
QoR report
hierarchical area report
timing path detail
```

추가.

---

# 15. Open Items

## STEP 3 미확정 항목

| # | 항목 | 상태 / 해야 할 일 |
|---|---|---|
| 1 | Hierarchy / file list | ✅ 완료 |
| 2 | UART RX 2-FF synchronizer | ✅ 완료 |
| 3 | APB top port names | ✅ 완료 |
| 4 | I/O delay | 🔶 SoC integration timing budget 확인 |
| 5 | Clock uncertainty | 🔶 기준 확정 |
| 6 | Clock transition | 🔶 기준 확정 |
| 7 | Output load | 🔶 기준 확정 |
| 8 | Driving cell | 🔶 GPDK045 cell 기준 결정 |
| 9 | Reset recovery/removal | 🔶 Signoff STA에서 정의 |
| 10 | STRICT_APB_ERR coverage | 🔶 필요 시 illegal-access 전체 audit |

---

# 16. Current Freeze Status

```text
STEP 1  Functional Freeze
        ✅ COMPLETE

STEP 2  Architecture Freeze
        ✅ COMPLETE

STEP 3  Synthesis Freeze
        ├── Top                 ✅ uart_apb
        ├── File list           ✅
        ├── FIFO depth          ✅ 8
        ├── STRICT_APB_ERR      ✅ 0
        ├── PCLK                ✅ 50 MHz
        ├── BAUD_DIV            ✅ 325
        ├── Async UART RX       ✅
        ├── 2-FF Synchronizer   ✅
        ├── Reset policy        ✅ initial synthesis
        ├── Slow corner         ✅
        ├── I/O delay           🔶
        ├── Clock uncertainty   🔶
        ├── Clock transition    🔶
        └── Load / drive        🔶

STEP 4  Genus Synthesis
        ⏳ NEXT

STEP 5  Reports / Check
        ⏳
```

---

# 17. Freeze Decision

UART V3 frontend는 현재 검증된 configuration을 기준으로 Freeze 한다.

다음 항목 변경 시 반드시 regression을 재실행한다.

```text
Register map
FIFO depth
UART TX / RX FSM
Baud generator
BAUD_DIV reset value
Frame format logic
IRQ behavior
Overflow behavior
APB transaction behavior
STRICT_APB_ERR functionality
```

아래 항목은 Backend constraint refinement로 간주하며 RTL regression 없이 수정 가능하다.

```text
Input delay
Output delay
Clock uncertainty
Clock transition
Output load
Driving cell
PVT / library view
Report configuration
```

단, constraint 변경이 functional assumption을 변경하는 경우 본 Freeze 문서를 다시 검토한다.

---

# 18. Revision History

| Date | Revision | 내용 |
|---|---|---|
| 2026-10-04 | Initial | FIFO depth 8 / STRICT_APB_ERR=0 / idle-only configuration / top=uart_apb |
| 2026-10-04 | Rev.1 | BAUD_DIV `(DIV+1)` 공식 반영 / 50 MHz reset=325 확정 / 실제 `i_uartRx` port 반영 |
| 2026-10-04 | **Rev.2** | 2-FF synchronizer 확인 / UART RX false-path 확정 / APB actual port 확정 / RX_DATA 1-cycle wait-state 반영 / reset recovery-removal 분리 / explicit APB I/O constraint 방식으로 수정 |
