# APR (Automatic Place & Route)

## 정의
- [[synthesis]]에서 나온 게이트 레벨 넷리스트를 **실제 실리콘 위의 물리적 좌표**로 배치(Place)하고, 셀 간 배선(Route)을 완성해 GDSII를 생성하는 전체 physical design 단계

## 주요 하위 단계
| 단계 | 설명 |
|:--|:--|
| Floorplan | 칩의 전체 면적, 매크로/IP 위치, 전원 링(power ring) 배치 결정 |
| Power Planning | 전원(VDD)/접지(VSS) 배선망(PDN) 설계 |
| Placement | 스탠다드 셀들을 floorplan 안의 실제 좌표에 배치 |
| CTS (Clock Tree Synthesis) | 모든 시퀀셜 셀에 클럭이 동일한 지연으로 도달하도록 클럭 트리 삽입 (skew 최소화) |
| Routing | 배치된 셀들 사이를 금속 배선으로 실제 연결 |
| Signoff | DRC(설계 규칙), LVS(레이아웃-회로 일치), STA(정적 타이밍 분석) 등 최종 검증 |

## Placement에서 중요한 것
- Timing-driven placement: critical path 상의 셀들을 서로 가깝게 배치해 배선 지연 최소화
- Congestion(배선 혼잡도)이 너무 높으면 routing 단계에서 실패 가능 → placement 단계에서 미리 완화

## Clock Tree Synthesis (CTS)
- 모든 FF까지의 클럭 도달 시간 차이(**skew**)를 최소화하는 것이 핵심 목표
- Skew가 크면 setup/hold 타이밍이 깨질 수 있음
- H-tree, buffer 삽입 등의 구조로 균등한 지연 경로를 만듦

## Signoff 체크
- **DRC**: 파운드리가 정한 최소 선폭/간격 등 제조 규칙 위반 여부
- **LVS**: 레이아웃에서 추출한 회로가 원래 netlist와 일치하는지
- **STA**: 실제 배선 지연(RC parasitic)까지 반영한 최종 타이밍 검증

## 결과물 — GDSII
- 파운드리에 넘겨 실제 마스크 제작에 사용되는 표준 레이아웃 포맷

## 본 프로젝트 연관
- Project Structure의 Stage 5 (APR), Design Flow의 마지막 단계
- `5_APR` 디렉터리에 floorplan/PnR 관련 스크립트와 결과물이 위치
