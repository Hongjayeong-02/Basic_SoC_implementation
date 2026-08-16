# Synthesis (합성)

## 정의
- RTL(동작 수준 Verilog 코드)을 **게이트 레벨 넷리스트**(AND/OR/FF 등 표준 셀의 연결)로 변환하는 과정
- 합성 도구가 목표 라이브러리(Standard Cell Library)를 참고해 논리를 매핑

## 입력 / 출력
| 입력 | 출력 |
|:--|:--|
| RTL 소스 (`.v`) | Gate-level netlist (`.v`, 셀 인스턴스만 존재) |
| 제약조건 (SDC: 클럭, I/O 딜레이 등) | 타이밍/면적/전력 리포트 |
| Standard Cell Library (`.lib`) | |

## 주요 개념
- **Timing constraints (SDC)**: 클럭 주기, setup/hold 여유, 입출력 지연 등을 정의 → 이 제약을 만족하도록 합성 도구가 게이트를 선택
- **Critical path**: 조합 로직 중 지연이 가장 긴 경로. 클럭 주기를 결정짓는 병목
- **Area / Power / Timing (PPA)**: 합성 최적화의 3대 축, 서로 트레이드오프 관계

## RCA vs CLA가 합성 리포트에 미치는 영향
- RCA: 게이트 수는 적지만 critical path가 길어 최대 클럭 주파수(Fmax)가 낮게 나옴
- CLA: 게이트 수는 늘지만 critical path가 짧아져 더 높은 Fmax 달성 가능
- → [[cla]] 문서의 개선이 실제로 합성 리포트 수치로 확인되는 지점

## 합성 후 확인해야 할 것
1. Timing violation(위반) 여부 (setup/hold)
2. 예상보다 큰 area를 차지하는 모듈 식별
3. Latch 의도치 않게 생성되지 않았는지 (조합 always 블록에서 모든 분기의 출력을 빠짐없이 대입했는지 확인)

## 본 프로젝트 연관
- Project Structure의 Stage 3 (Synthesis)에 해당
- 합성 결과 netlist는 다음 단계인 [[equivalence]](RTL-netlist 등가성 검증)와 [[apr]](Place & Route)의 입력으로 사용됨
