# Git Workflow (본 프로젝트 표준)

> 실제 브랜치 전략/커밋 규칙은 본인 습관에 맞게 채워 넣는 문서. 아래는 RTL 마일스톤 구조에 맞춘 기본 템플릿.

## 브랜치 전략 (제안)
```
main                     # 항상 동작하는 상태만 유지 (README 기준선)
 └─ milestone/01-alu-basic
 └─ milestone/02-rca-to-cla
 └─ milestone/03-alu-logic
 └─ milestone/04-alu-mul-div
 └─ milestone/05-final-alu
```
- 마일스톤 하나 = 브랜치 하나 → 완료 시 `main`에 머지
- 머지 전 최소 기준: 시뮬레이션 PASS ([[testbench]] 기준 통과) 확인

## 커밋 메시지 컨벤션 (제안)
```
[RTL] 04_ALU_MUL_DIV: signed division 구현
[SIM] 05_FINAL_ALU: UART parser FSM 테스트벤치 추가
[DOCS] study_notes: cla.md 작성
[FIX] adder: carry propagation 버그 수정
```
- 접두사로 어떤 단계(RTL/SIM/SYN/EC/APR/DOCS/FIX)의 변경인지 구분 → Project Structure 단계와 자연스럽게 매핑

## .gitignore 관리
- 시뮬레이션 부산물(`*.log`, `*.history`, `xcelium.d/`, `.simvision/*.log`)은 추적 제외
- 단, `.simvision/*-bookmarks`는 파형 뷰 설정 복원에 유용하므로 추적 유지 고려

## 커밋 단위 원칙
- RTL 변경과 TB 변경은 가능하면 같은 커밋에 묶어서, "이 기능을 추가했고 이렇게 검증했다"가 커밋 히스토리만으로 드러나게 함

## 본 프로젝트 연관
- 커밋 히스토리 자체가 README의 Roadmap(완료/미완료 체크리스트)과 대응되도록 관리하는 것이 포트폴리오 관점에서 유리
