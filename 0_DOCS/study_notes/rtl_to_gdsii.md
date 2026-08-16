# RTL-to-GDSII Flow — 전체 요약

이 문서는 [[verilog_rtl]], [[synthesis]], [[equivalence]], [[apr]] 각 문서에서 다룬 단계를 하나의 흐름으로 엮은 요약본입니다.

```
1_RTL                2_SIM                 3_SYN
Verilog Design  ──▶  Functional        ──▶  RTL → Gate-level
                     Verification            Netlist
                                                  │
                                                  ▼
                     5_APR             ◀──   4_EC
                     Place & Route  ◀──       RTL vs Netlist
                     → GDSII                  Equivalence Check
```

## 단계별 한 줄 요약
| 단계 | 무엇을 하는가 | 산출물 |
|:--|:--|:--|
| 1. RTL | Verilog로 동작을 기술 | `.v` 소스 |
| 2. SIM | 테스트벤치로 기능 검증 | 파형(VCD/shm), PASS/FAIL 로그 |
| 3. SYN | 게이트 레벨로 변환 | Gate-level netlist |
| 4. EC | RTL과 netlist가 같은 기능인지 형식 검증 | Match/Mismatch 리포트 |
| 5. APR | 물리적 배치·배선 | GDSII |

## 이 흐름을 직접 겪으며 느낀 점 정리용 섹션
> (여기에 실제로 각 단계에서 겪었던 이슈, 삽질, 배운 점을 프로젝트 진행하면서 채워 넣기 — 포트폴리오로서 가장 가치 있는 부분)

- [ ] RTL 단계에서 겪은 이슈:
- [ ] SIM 단계에서 겪은 이슈:
- [ ] SYN 단계에서 겪은 이슈:
- [ ] EC 단계에서 겪은 이슈:
- [ ] APR 단계에서 겪은 이슈:

## 본 프로젝트 연관
- README의 "Design Flow" mermaid 다이어그램의 텍스트/서술 버전
- 각 단계의 세부 개념은 개별 문서([[synthesis]], [[equivalence]], [[apr]])를 참고
