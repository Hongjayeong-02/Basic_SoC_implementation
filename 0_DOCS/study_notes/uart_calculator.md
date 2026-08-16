# UART Calculator (05_FINAL_ALU 설계 노트)

이 문서는 README의 "Final ALU" 섹션 뒤에 있는 **실제 설계 의도와 내부 구조**를 정리한 문서입니다. [[uart]], [[fsm]] 문서와 함께 보면 좋습니다.

## 전체 데이터 흐름
```
UART RX → Command Parser → ALU → Encoder → UART TX
```

## Command Parser
- UART로 들어온 ASCII 문자열(예: `ISF6*02=`)을 해석해 피연산자/연산자를 추출하는 FSM
- 예상 입력 포맷 추정:
  - 첫 글자: 부호 지정 (예: `I` = signed, `U` = unsigned 등 프로젝트 규약에 따라 정의)
  - 이후: 피연산자 (hex 형태로 보임, 예: `SF6`, `10`)
  - 연산자: `+`, `-`, `*`, `/` 등 ASCII 그대로
  - `=`: 명령어 종료(연산 실행 트리거)
- FSM 상태 예시: `IDLE → READ_SIGN → READ_OPERAND1 → READ_OP → READ_OPERAND2 → EXEC → DONE`

## ALU 연동
- Parser가 추출한 피연산자/연산자를 ALU의 `i_a`, `i_b`, `i_op`에 그대로 연결
- ALU는 [[adder]]/[[cla]]/[[multiplier]]/[[division]] 서브모듈을 `i_op`로 선택해 실행

## Encoder
- ALU의 이진 결과값을 다시 ASCII(HEX 문자)로 인코딩해 UART TX로 내보냄
- 예: 결과값 `8'hEC` → 문자 `'E'`, `'C'` 두 바이트로 변환해 순서대로 전송

## 검증 예시 (README Example 섹션과 연결)
| Input | 의미(추정) | Result |
|:--|:--|:--|
| `ISF6*02=` | signed 0xF6 × 0x02 | `EC` |
| `IU10/04=` | unsigned 0x10 ÷ 0x04 | `04` |
| `ISF00*02=` | signed 0xF00... × 0x02 | `00` |

## 본 프로젝트 연관
- README "Final ALU" 섹션의 Data Flow/Supported Operations/Example의 구현 배경 설명
- RTL 마일스톤 `01~04`에서 만든 서브모듈(ALU_BASIC, CLA, LOGIC, MUL_DIV)이 `05_FINAL_ALU`에서 UART 인터페이스로 통합되는 지점
