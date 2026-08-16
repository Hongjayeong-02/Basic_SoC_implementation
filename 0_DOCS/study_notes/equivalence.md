# Equivalence Check (LEC — Logical Equivalence Check)

## 목적
- [[synthesis]] 전(RTL)과 후(gate-level netlist), 혹은 [[apr]] 전/후의 두 설계가 **기능적으로 완전히 동일한지** 수학적으로 증명
- 시뮬레이션은 "테스트한 케이스만" 검증하지만, LEC은 **모든 입력 조합에 대해 형식적으로(formal)** 동등성을 증명 → 시뮬레이션으로 놓칠 수 있는 케이스까지 커버

## 비교 대상
| 비교 | 목적 |
|:--|:--|
| RTL vs Synthesized netlist | 합성 과정에서 논리가 왜곡되지 않았는지 확인 |
| Pre-APR netlist vs Post-APR netlist | Place & Route(클럭 트리 삽입, 버퍼 삽입 등) 이후에도 기능이 동일한지 확인 |

## 동작 원리 (개념)
- 두 설계를 각각 논리 함수로 표현하고, 대응되는 입력/출력 핀을 매핑(mapping)
- 두 함수의 출력이 모든 입력 조합에서 같은지를 SAT/BDD 기반 알고리즘으로 증명
- "매치(Match)" / "미스매치(Mismatch)" / "미대응(Not Mapped)" 로 결과 분류

## 왜 시뮬레이션만으로는 부족한가
- 시뮬레이션은 작성한 테스트벡터 범위 내에서만 정확성을 보장
- 합성 도구의 최적화(리소스 공유, 상수 전파 등) 과정에서 미묘한 버그가 생겨도 특정 테스트 케이스에서는 우연히 드러나지 않을 수 있음
- LEC은 이런 사각지대를 형식적으로 제거

## 본 프로젝트 연관
- Project Structure의 Stage 4 (Equivalence Check)에 해당
- RTL → Synthesis → **EC** → APR 순서로, 각 단계 전환마다 설계가 깨지지 않았음을 보증하는 게이트 역할
