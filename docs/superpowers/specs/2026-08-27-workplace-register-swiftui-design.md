# 근무지 등록/수정 SwiftUI 재구현 설계

- 이슈: [#113](https://github.com/5-rganization/MOUP-iOS/issues/113) (부모 [#115](https://github.com/5-rganization/MOUP-iOS/issues/115))
- 브랜치: `task/#113`, base `task/#115`
- 작성일: 2026-08-27

## 배경

부모 이슈 #115(근무/근무지 입력 폼 SwiftUI 재구현)의 하위 4개 중 3개(#116, #117, #112)가 완료됐고 #113만 남았다.
`Presentation/WorkplaceRegister/`는 아직 100% UIKit + RxSwift다.

#112에서 확립된 패턴을 그대로 따른다.

- 값 타입 `XxxForm`이 폼 상태와 DTO 변환을 담당하고, View가 `@State`로 소유한다
- 루트 뷰가 `NavigationStack` 하나를 갖고, 하위 화면은 `.navigationDestination(isPresented:)`로 push
- 모달 피커는 `.sheet`, 알림/확인 모달만 주입받은 `UINavigationController.presentNoticeModal(...)`
- Coordinator는 루트를 `UIHostingController`로 감싸 한 번만 push

## 범위

세 루트 화면이 하위 위저드를 공유하므로 셋 다 포함한다. 초대코드 화면은 이슈 문구에 없지만
같은 위저드를 쓰기 때문에 제외하면 위저드가 UIKit·SwiftUI 두 벌로 남는다.

| 루트 화면 | 현재 위치 | 근무지 | 급여 | 근무조건 | 색상라벨 |
|---|---|---|---|---|---|
| 알바생 직접 등록/수정 | `Presentation/WorkplaceRegister/` | O | O | O | O |
| 사장님 등록/수정 | `Presentation/WorkplaceRegister/` | O | - | - | O |
| 초대코드 참여 | `Presentation/Home/` | 읽기전용 | O | O | O |

범위 밖:

- 수정 모드 UX 변경 — #112가 도입한 잠금/편집 토글(`isEditing`)은 적용하지 않는다. 현재의 즉시 편집 동작을 유지한다
- 근무지 등록 진입 시트(`WorkplaceRegisterSheetViewController`) — UIKit 그대로 둔다
- 주소/좌표 입력 — 현재 `address: "기본 주소"`, `latitude/longitude: 0.0`으로 하드코딩돼 있다. 그대로 재현한다

## 접근

세 루트의 필드가 부분집합 관계이므로 **단일 `WorkplaceForm` + 섹션 뷰 조합**으로 간다.
루트마다 Form을 따로 두면(#112의 `MyWorkForm`/`WorkerWorkForm` 방식) DTO 변환과 파생 프로퍼티가 3벌로 복제된다.

검토했다가 버린 대안:

- **단일 루트 뷰 + `Variant` enum 분기** — `body` 안에 3중 조건 분기가 들어가고 저장 API·타이틀·완료 문구가 switch로 흩어진다. 현재 UIKit의 `isOwnerInjected` 분기 구조로 되돌아가는 셈
- **루트별 Form 3개** — 근무지는 근무와 달리 필드가 부분집합이라 분리할 이유가 없다

## 파일 구조

```
Presentation/InputForm/WorkplaceRegister/
  WorkplaceForm.swift                    # 값 타입 + isValid + DTO 변환 4종 + 상세 프리필
  WorkplaceRegisterView.swift            # 알바생 직접 등록/수정 루트
  OwnerWorkplaceRegisterView.swift       # 사장님 등록/수정 루트
  InviteCodeWorkplaceRegisterView.swift  # 초대코드 참여 루트
  Sections/
    WorkplaceSection.swift               # 이름 · 카테고리
    PaySection.swift                     # 급여형태 · 계산방식 · 금액 · 급여일
    WorkingConditionsSection.swift       # 체크박스 8개
    ColorLabelSection.swift              # 색상라벨
  Wizard/
    CategorySelectView.swift
    NameInputView.swift
    PayTypeSelectView.swift
    PayCalculationSelectView.swift
    SalaryInputView.swift
    ColorLabelSelectView.swift
    PayDayPickerSheet.swift
```

15파일. 현재 45파일 5,476줄 → 1,600~1,800줄 예상.

기존 컴포넌트를 재사용한다. 새로 만들지 않는다.

- `RadioButtonView` — 카테고리·급여형태·계산방식·색상라벨 선택 (#117에서 이 화면용으로 미리 만들어 둔 것, 현재 사용처 없음)
- `WizardTextFieldView` — 근무지 이름, 급여 금액(콤마·원 포매팅)
- `CheckBoxRow` — 근무조건 체크박스 8개 (#116)
- `ContainerView`, `LabelChevronRowView`, `FormRowButtonStyle`, `BaseNavigationBarSU`, `BaseButtonSU`

## 상태 모델

```swift
struct WorkplaceForm: Equatable {
    var workplaceName: String
    var categoryName: String
    var labelColor: LabelColor
    var salaryType: SalaryType
    var salaryCalculation: SalaryCalculation
    var salaryAmount: Int          // 계산방식에 따라 hourlyRate 또는 fixedRate로 전송
    var payDay: Int                // salaryDate
    var hasNationalPension: Bool
    var hasHealthInsurance: Bool
    var hasEmploymentInsurance: Bool
    var hasIndustrialAccident: Bool
    var hasIncomeTax: Bool
    var hasHolidayAllowance: Bool
    var hasNightAllowance: Bool
}
```

- `LabelColor`(`Presentation/Utils/Enums/`), `SalaryType`·`SalaryCalculation`(`Domain/Entities/Salary/`)은 이미 서버 문자열 매핑을 갖고 있다. 그대로 쓴다
- "4대 보험" 마스터 체크박스는 저장하지 않는다. 표시 상태는 국민연금·건강보험·고용보험·산재보험 4개가 모두 켜졌는지의 파생 값이고, 탭하면 4개를 그 반대 값으로 일괄 설정한다
- 등록 모드는 기본값 이니셜라이저, 수정 모드는 `init(detail: WorkplaceDetailResponseDTO)`로 프리필한다
- `isValid`는 루트마다 다르다. 완료 버튼 활성화에 쓴다
  - 알바생 직접 등록: 이름 · 카테고리 · 색상 · 급여형태 · 계산방식이 채워지고 `salaryAmount > 0`
  - 사장님: 이름 · 카테고리 · 색상
  - 초대코드 참여: 색상 · 급여형태 · 계산방식 · `salaryAmount > 0` (이름·카테고리는 초대코드가 결정)
  - 루트별 조건이므로 `WorkplaceForm`에 세 개의 계산 프로퍼티로 둔다

DTO 변환 4종:

| 프로퍼티 | 대상 DTO | 사용처 |
|---|---|---|
| `createRequestDTO` | `WorkplaceCreateRequestDTO` | 알바생 직접 등록 |
| `ownerCreateRequestDTO` | `OwnerWorkplaceCreateRequestDTO` | 사장님 등록 |
| `joinRequestDTO(inviteCode:)` | `WorkplaceJoinRequestDTO` | 초대코드 참여 |
| `updateRequestDTO` | `UpdateWorkplaceRequestDTO` | 알바생·사장님 수정 |

서버 스펙의 비대칭을 그대로 재현한다.

- 색상 키가 역할별로 다르다: 알바생 `workerBasedLabelColor`, 사장님 `ownerBasedLabelColor`
- `SalaryJoinCreateRequest`(초대코드)만 `fixedRate`·`salaryDay`를 갖는다. 직접 등록용 `SalaryCreateRequest`에는 없다
- 초대코드 참여의 `salaryDay`는 현재 `"MONDAY"` 하드코딩이다. 동작을 바꾸지 않기 위해 유지하되 주석으로 표시한다
- 계산방식이 시급이면 `hourlyRate`에, 아니면 `fixedRate`에 `salaryAmount`를 넣고 나머지는 `nil`

## 네비게이션

루트 뷰가 `@State private var form`을 소유하고, 섹션 뷰는 `@Binding var form: WorkplaceForm`을 받는다.
행을 탭하면 루트의 `@State private var showCategorySelect = true`가 서고 `.navigationDestination(isPresented:)`가 push 한다.
위저드 화면은 필요한 필드만 `@Binding`으로 받는다 — 예: `CategorySelectView(categoryName: $form.categoryName)`.

급여일 선택만 `.sheet`로 띄운다(현재 UIKit도 `present`).
알림·확인 모달은 `NoticeModalViewControllerSU`를 쓰지 않고 주입받은 `navigationController.presentNoticeModal(...)`을 쓴다.

초대코드 루트는 `WorkplaceSection` 대신 읽기전용 이름 표시를 두고 `PaySection`부터 재사용한다.

## Coordinator 배선

**`WorkplaceRegisterCoordinator`** — `lazy var` ViewModel 9개와 `show*()` 7개를 전부 삭제한다.
위저드 전환이 SwiftUI로 내려가므로 루트 push만 남는다. `isOwner`에 따라 `UIHostingController`를 분기해 만든다
(`AnyView`로 감싸지 않는다 — `CalendarCoordinator.showWorkerWorkRegister`/`showOwnerWorkRegister` 선례를 따른다).

**`WorkplaceRegisterCoordinatorProtocol` 삭제** — `show*()` 7개만 정의한 프로토콜이라 존재 이유가 사라진다.
`InviteCodeInputCoordinator`가 이를 채택하고 7개를 전부 빈 `return`으로 구현해 둔 죽은 코드도 함께 없어진다.

**`InviteCodeInputCoordinator`** — `lazy var` ViewModel 6개 삭제, `moveToInviteCodeWorkplaceRegister`가 `UIHostingController` push로 바뀐다.

**`WorkplaceRegisterSheetCoordinator`** — 시트는 UIKit 그대로. `moveToDirectRegistration`이 새 Coordinator를 탄다.

진입점 4곳(`HomeViewController` 3곳, `WorkplaceRegisterSheetViewController` 1곳)은 시그니처가 안 바뀌므로 수정하지 않는다.

`WorkplaceUseCaseProtocol`은 손대지 않는다. `createWorkplace` / `createOwnerWorkplace` / `joinWorkplace` /
`updateWorkplace` / `fetchWorkplaceDetail`이 모두 이미 있다. 수정 모드는 #112와 동일하게 진입 후 상세를 조회해 채운다.

## 삭제 범위

| 대상 | 규모 |
|---|---|
| `Presentation/WorkplaceRegister/` | 45파일 / 5,476줄 (`Utils/OLDCustomTextField.swift` 제외 — 아래 참고) |
| `Presentation/Home/`의 초대코드 등록 3파일 | 421줄 |
| `Coordinator/.../WorkplaceRegisterCoordinatorProtocol.swift` | 16줄 |
| `Presentation/WorkRegister/` (구 UIKit 근무 등록, 고립됨) | 27파일 / 4,527줄 |
| `Coordinator/WorkRegister/` (고립됨) | 2파일 / 151줄 |

`Presentation/WorkRegister/`와 `Coordinator/WorkRegister/`는 전 심볼을 대조한 결과 폴더 밖 참조가 없다.
`WorkRegisterCoordinator`를 인스턴스화하는 곳이 없어 #112 이후 완전히 죽은 코드가 됐다.
(`RoleSegmentedView.swift`에 `OLDRoleSegmentedControl` 언급이 있으나 주석 문장이고 코드 참조가 아니다.)

`Presentation/WorkplaceRegister/Utils/` 4개는 따로 처리한다.

- `OLDCustomTextField` — `Routine/AddRoutineView`, `Routine/EditRoutineView`, `MyPage/EditModal`이 **현재 사용 중**이다. 지우지 말고 `Presentation/Utils/`로 옮긴다
- `OLDInfoRowView`, `OLDContainerView`, `OLDRadioButtonView` — 근무지 밖 사용처가 `Presentation/WorkRegister/`뿐이므로 함께 삭제한다

## 근무 폼 리팩토링 (#112 후속)

`MyWorkForm`(210줄)과 `WorkerWorkForm`(238줄)에 주석까지 동일한 코드가 약 110줄 중복돼 있다.
야간 근무 익일 처리와 `yyyy-MM-dd` 포맷(다른 포맷은 422) 같은 비자명한 규칙이 두 벌이라, 한쪽만 고치면 조용히 어긋난다.

공유 8필드를 요구사항으로 하는 프로토콜에 파생 로직을 모은다.

```swift
// Presentation/InputForm/WorkRegister/WorkFormSchedule.swift
protocol WorkFormSchedule {
    var selectedDate: Date { get }
    var selectedStartTime: Date { get }
    var selectedEndTime: Date { get }
    var selectedBreakTime: Int { get }
    var repeatDays: [String] { get }
    var repeatEndDate: Date? { get }
    var routines: [RoutineSummary] { get }
    var memo: String { get }
}
```

익스텐션이 제공하는 것:

- 표시용 6개 — `formattedStartTime`, `formattedEndTime`, `formattedBreakTime`, `hasRepeat`, `formattedRepeatDays`, `formattedRoutineCount`
- 시각 계산 5개 — `combined(_:)`, `startDateTime`, `endDateTime`, `repeatEndDateString`, `repeatDaysForRequest`
- 본인 근무 DTO 2개 — `myCreateRequestDTO`, `myUpdateRequestDTO`

각 struct에 남는 것:

- `isValid` — 조건이 다르다. 알바생은 근무지 + 시간, 사장님은 거기에 `target == .owner || !selectedWorkers.isEmpty`
- `WorkerWorkForm` 전용 — `workersCreateRequestDTO`, `updateRequestDTO`(근무자용), `formattedWorkers`
- `MyWorkForm` 전용 — `actualStartTime`, `actualEndTime`(표시 전용, DTO에는 항상 `nil` 전송)

필드는 각 struct에 그대로 두므로 **뷰 코드는 바뀌지 않는다.** `form.formattedRepeatDays`, `form.startDateTime` 접근 경로가 동일하다.
`MyWorkForm.createRequestDTO`/`updateRequestDTO`만 `myCreateRequestDTO`/`myUpdateRequestDTO`로 이름을 맞춘다.

## 작업 순서

각 단계는 빌드가 통과하는 단위다.

| # | 작업 | 커밋 |
|---|---|---|
| 1 | 근무 폼 공통 로직을 `WorkFormSchedule`로 추출 | `refactor: #112 - 근무 폼의 공통 파생 로직 추출` |
| 2 | 고립된 구 UIKit 근무 등록 코드 29파일 삭제 | `chore: #112 - 미사용 UIKit 근무 등록 코드 제거` |
| 3 | `WorkplaceForm` + 위저드 7화면 + 섹션 4개 | `feat: #113 - 근무지 폼 상태 모델 및 공통 뷰 구현` |
| 4 | 알바생 루트 + Coordinator 연결 | `feat: #113 - 알바생 근무지 등록/수정 화면 SwiftUI 재구현` |
| 5 | 사장님 루트 | `feat: #113 - 사장님 근무지 등록/수정 화면 SwiftUI 재구현` |
| 6 | 초대코드 참여 루트 | `feat: #113 - 초대코드 근무지 참여 화면 SwiftUI 재구현` |
| 7 | 구 근무지 UIKit 삭제 + `OLDCustomTextField` 이동 | `chore: #113 - 구 UIKit 근무지 등록 코드 제거` |
| 8 | CLAUDE.md 갱신 | `chore: #113 - CLAUDE.md의 진행 중인 작업 절 갱신` |

7을 4·5·6 뒤로 미루는 이유: 세 루트를 다 옮기기 전에는 구 코드가 참조로 남아 빌드가 깨진다.

1·2는 #113 범위 밖의 #112 후속 정리라 이슈번호를 `#112`로 단다.

## 검증

테스트 타겟이 없으므로 시뮬레이터 실행이 유일한 검증 수단이다. 기준은 iPhone 13 mini / iOS 16.0.

```bash
xcodebuild -workspace MOUP/MOUP.xcworkspace -scheme MOUP \
  -destination 'platform=iOS Simulator,name=iPhone 13 mini,OS=16.0' build
```

4·5·6 각 단계마다 확인할 것:

- 등록 플로우 — 위저드 7화면 진입/복귀, 필수 필드 미입력 시 완료 버튼 비활성화, 저장 후 홈 목록 반영
- 수정 플로우 — 상세 조회 프리필, 값 변경 후 저장, 색상 키가 역할에 맞게 전송되는지
- 스와이프 백 제스처 — `NavigationControllerFinder` 브릿지가 필요한지 확인
- 초대코드 참여 — 시급/월급 계산방식에 따라 `hourlyRate`/`fixedRate` 중 하나만 전송되는지
