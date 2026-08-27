# 근무지 등록/수정 SwiftUI 재구현 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 근무지 등록/수정 화면 3종(알바생 직접 등록, 사장님, 초대코드 참여)을 UIKit + RxSwift에서 SwiftUI로 재구현하고, 구 UIKit 코드와 이미 죽은 근무 등록 UIKit 코드를 제거한다.

**Architecture:** 값 타입 `WorkplaceForm` 하나가 세 화면의 폼 상태와 DTO 변환을 모두 담는다. 섹션 뷰 4개가 `@Binding var form`을 받아 행을 그리고, 위저드 화면 7개는 필요한 필드만 `@Binding`으로 받는다. 루트 뷰 3개는 `NavigationStack` 하나씩을 갖고 필요한 섹션만 조합하며, Coordinator가 루트를 `UIHostingController`로 감싸 한 번만 push 한다.

**Tech Stack:** Swift 5, SwiftUI (iOS 16 최소 타깃), UIKit 네비게이션 상호운용, async/await, Alamofire Router 기반 기존 `WorkplaceUseCase`

**Spec:** `docs/superpowers/specs/2026-08-27-workplace-register-swiftui-design.md`

## Global Constraints

- 최소 배포 타깃 **iOS 16.0**. `onChange(of:initial:_:)`, `@Observable` 등 iOS 17 API 금지. 기존 코드처럼 `onChange(of:) { newValue in }` 2-파라미터 형태를 쓰고 deprecated 주석을 단다
- 빌드는 반드시 **`MOUP/MOUP.xcworkspace`**로 한다. `.xcodeproj`는 CocoaPods 의존성이 빠져 실패한다
- 검증 시뮬레이터는 **iPhone 13 mini / iOS 16.0**
- **테스트 타겟이 없다.** 각 태스크의 검증은 `xcodebuild build` 통과 + 시뮬레이터 수동 플로우 확인이다
- 커밋 메시지: `type: #113 - 한글 설명`, 설명은 **명사형 어미**(`~ 추가`, `~ 구현`, `~ 수정`, `~ 제거`, `~ 변경`). 쓰는 타입은 `feat`, `fix`, `refactor`, `chore`, `rename`
- 커밋은 **빌드가 통과하는 단위**로 남긴다. 컴파일이 깨진 중간 상태를 커밋하지 않는다
- 각 태스크를 끝낼 때 **이 플랜 문서의 체크박스를 체크한 것도 같은 커밋에 포함**한다
- 새 컴포넌트를 만들기 전에 `Presentation/InputForm/Components/`에 이미 있는지 확인한다. 있으면 그것을 쓴다
- 알림/확인 모달은 `NoticeModalViewControllerSU`를 쓰지 않는다. 주입받은 `UINavigationController`의 `presentNoticeModal(...)`을 쓴다
- SwiftUI 안에서 `UINavigationController`를 탐색하지 않는다. Coordinator가 주입한 것만 쓴다
- 브랜치 `task/#113` (base `task/#115`)에서 작업한다
- Xcode 프로젝트는 `PBXFileSystemSynchronizedRootGroup`(경로 `MOUP`)을 쓴다. **파일을 추가·삭제해도 `project.pbxproj`를 손댈 필요가 없다.** 디스크에 파일을 두면 타깃에 자동 편입된다

**빌드 명령 (모든 태스크 공통):**

```bash
cd /Users/macmillan/Projects/XcodeProjects/5rganization/MOUP/MOUP-iOS
xcodebuild -workspace MOUP/MOUP.xcworkspace -scheme MOUP \
  -destination 'platform=iOS Simulator,name=iPhone 13 mini,OS=16.0' build
```

---

### Task 1: 근무 폼 공통 파생 로직 추출

`MyWorkForm`(210줄)과 `WorkerWorkForm`(238줄)에 주석까지 동일한 코드가 약 110줄 중복돼 있다. 야간 근무 익일 처리와 `yyyy-MM-dd` 포맷(다른 포맷은 서버가 422 반환) 같은 비자명한 규칙이 두 벌이라 한쪽만 고치면 조용히 어긋난다.

**Files:**
- Create: `MOUP/MOUP/Presentation/InputForm/WorkRegister/WorkFormSchedule.swift`
- Modify: `MOUP/MOUP/Presentation/InputForm/WorkRegister/MyWork/MyWorkForm.swift`
- Modify: `MOUP/MOUP/Presentation/InputForm/WorkRegister/WorkerWork/WorkerWorkForm.swift`
- Modify: `MOUP/MOUP/Presentation/InputForm/WorkRegister/MyWork/MyWorkFormView.swift` (DTO 프로퍼티 이름 변경분만)

**Interfaces:**
- Consumes: 없음
- Produces: `protocol WorkFormSchedule`. 채택 타입에 `formattedStartTime: String`, `formattedEndTime: String`, `formattedBreakTime: String`, `hasRepeat: Bool`, `formattedRepeatDays: String`, `formattedRoutineCount: String`, `startDateTime: Date`, `endDateTime: Date`, `myCreateRequestDTO: MyWorkCreateRequestDTO`, `myUpdateRequestDTO: MyWorkUpdateRequestDTO`를 제공한다

- [x] **Step 1: `WorkFormSchedule.swift` 생성**

```swift
//
//  WorkFormSchedule.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import Foundation

/// 근무 폼이 공유하는 일정 필드와 그로부터 파생되는 표시·전송 값
///
/// `MyWorkForm`과 `WorkerWorkForm`이 같은 일정 필드를 갖고 같은 규칙으로 파생 값을 만든다.
/// 두 곳에 복제해 두면 야간 근무 처리나 날짜 포맷 규칙을 한쪽만 고치는 사고가 난다.
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

// MARK: - 표시용 파생 값

extension WorkFormSchedule {

    var formattedStartTime: String {
        DateFormatter.startEndTimeDateFormatter.string(from: selectedStartTime)
    }

    var formattedEndTime: String {
        DateFormatter.startEndTimeDateFormatter.string(from: selectedEndTime)
    }

    var formattedBreakTime: String {
        selectedBreakTime == 0 ? "없음" : "\(selectedBreakTime)분"
    }

    /// 반복 여부
    var hasRepeat: Bool {
        !repeatDays.isEmpty && repeatEndDate != nil
    }

    /// 반복 요일 표시 텍스트
    var formattedRepeatDays: String {
        hasRepeat ? RepeatDays.formatted(repeatDays) : "없음"
    }

    var formattedRoutineCount: String {
        routines.isEmpty ? "" : "+ \(routines.count)"
    }
}

// MARK: - 시각 계산

extension WorkFormSchedule {

    /// `selectedDate`의 연·월·일과 `time`의 시·분을 합쳐 절대 시각을 만든다.
    ///
    /// 날짜와 시각을 별도 필드로 관리하기 때문에, 서버로 보낼 때는 하나로 합쳐야 한다.
    private func combined(_ time: Date) -> Date {
        let calendar = Calendar.current
        var comp = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComp = calendar.dateComponents([.hour, .minute], from: time)
        comp.hour = timeComp.hour
        comp.minute = timeComp.minute
        comp.second = 0
        return calendar.date(from: comp) ?? selectedDate
    }

    /// 출근 시각 (근무 날짜 기준)
    var startDateTime: Date {
        combined(selectedStartTime)
    }

    /// 퇴근 시각 (근무 날짜 기준)
    ///
    /// 퇴근이 출근보다 이르면 야간 근무로 보고 익일로 넘긴다. (예: 22:00 ~ 06:00)
    var endDateTime: Date {
        let end = combined(selectedEndTime)
        guard end <= startDateTime else { return end }
        return Calendar.current.date(byAdding: .day, value: 1, to: end) ?? end
    }

    /// 반복 종료일 문자열. 반복 설정이 완전하지 않으면 `nil`
    ///
    /// 서버는 `yyyy-MM-dd` 포맷을 요구한다. 표시용인 `dataSourceDateFormatter`(`yyyy.MM.dd`)를 쓰면 422가 반환된다.
    var repeatEndDateString: String? {
        guard hasRepeat, let repeatEndDate else { return nil }
        return DateFormatter.yyyyMMdd.string(from: repeatEndDate)
    }

    /// 반복 요일 목록. 반복 설정이 완전하지 않으면 빈 배열
    ///
    /// `repeatEndDateString`과 짝을 맞춰 요일만 선택하고 종료일을 비운 상태가 전송되지 않도록 한다.
    var repeatDaysForRequest: [String] {
        hasRepeat ? repeatDays : []
    }
}

// MARK: - 본인 근무 DTO 변환

extension WorkFormSchedule {

    /// 본인 근무 등록 요청 DTO
    var myCreateRequestDTO: MyWorkCreateRequestDTO {
        MyWorkCreateRequestDTO(
            routineIdList: routines.map { $0.routineId },
            startTime: startDateTime,
            // 서버가 nil을 "변경 없음"으로 보는지 "삭제"로 보는지 확인되지 않아, 기존 동작대로 항상 nil을 보낸다.
            actualStartTime: nil,
            endTime: endDateTime,
            actualEndTime: nil,
            restTimeMinutes: selectedBreakTime,
            memo: memo.isEmpty ? nil : memo,
            repeatDays: repeatDaysForRequest,
            repeatEndDate: repeatEndDateString
        )
    }

    /// 본인 근무 수정 요청 DTO
    ///
    /// 근무자 근무 수정 DTO와 달리 루틴을 포함한다. 본인 근무를 근무자 근무 DTO로 보내면 루틴이 지워진다.
    var myUpdateRequestDTO: MyWorkUpdateRequestDTO {
        MyWorkUpdateRequestDTO(
            routineIdList: routines.map { $0.routineId },
            startTime: startDateTime,
            actualStartTime: nil,
            endTime: endDateTime,
            actualEndTime: nil,
            restTimeMinutes: selectedBreakTime,
            memo: memo.isEmpty ? nil : memo,
            repeatDays: repeatDaysForRequest,
            repeatEndDate: repeatEndDateString
        )
    }
}
```

- [x] **Step 2: `MyWorkForm`에서 중복분 제거**

`struct MyWorkForm: Equatable`을 `struct MyWorkForm: Equatable, WorkFormSchedule`로 바꾼다.

`MARK: - DTO 변환` 익스텐션에서 아래를 **삭제**한다 (프로토콜 익스텐션이 제공한다):
`combined(_:)`, `startDateTime`, `endDateTime`, `repeatEndDateString`, `repeatDaysForRequest`, `createRequestDTO`, `updateRequestDTO`

struct 본문의 파생 프로퍼티 중 아래를 **삭제**한다:
`formattedStartTime`, `formattedEndTime`, `formattedBreakTime`, `hasRepeat`, `formattedRepeatDays`, `formattedRoutineCount`

**남기는 것:** 저장 프로퍼티 전부, 두 이니셜라이저, `formattedDate`, `isValid`.

`MARK: - DTO 변환` 익스텐션이 비면 익스텐션째 삭제한다.

- [x] **Step 3: `WorkerWorkForm`에서 중복분 제거**

`struct WorkerWorkForm: Equatable`을 `struct WorkerWorkForm: Equatable, WorkFormSchedule`로 바꾼다.

Step 2와 같은 목록을 삭제하되, `myCreateRequestDTO`와 `myUpdateRequestDTO`도 삭제한다 (프로토콜 익스텐션이 제공한다).

**남기는 것:** 저장 프로퍼티 전부, 두 이니셜라이저, `formattedDate`, `formattedWorkers`, `isValid`, `workersCreateRequestDTO`, `updateRequestDTO`(근무자용).

- [x] **Step 4: `MyWorkFormView`의 DTO 프로퍼티 이름 변경**

`MyWorkFormView.save(appliesToRecurring:)`에서 `form.createRequestDTO` → `form.myCreateRequestDTO`, `form.updateRequestDTO` → `form.myUpdateRequestDTO`로 바꾼다. 3곳이다.

```bash
grep -n "form.createRequestDTO\|form.updateRequestDTO" \
  MOUP/MOUP/Presentation/InputForm/WorkRegister/MyWork/MyWorkFormView.swift
```

- [x] **Step 5: 빌드**

Run: 위 "빌드 명령"
Expected: `** BUILD SUCCEEDED **`

실패하면 남은 참조를 찾는다:
```bash
grep -rn "\.createRequestDTO\|\.updateRequestDTO" --include="*.swift" MOUP/MOUP/Presentation/InputForm/
```

- [ ] **Step 6: 시뮬레이터 확인**

캘린더 → 근무 등록/수정 진입. 반복 설정과 휴게시간 표시가 이전과 같은지, 저장이 되는지 확인한다. 파생 값만 옮겼으므로 화면은 동일해야 한다.

- [x] **Step 7: 커밋**

```bash
git add MOUP/MOUP/Presentation/InputForm/WorkRegister/ docs/superpowers/plans/2026-08-27-workplace-register-swiftui.md
git commit -m "refactor: #113 - 근무 폼의 공통 파생 로직 추출"
```

---

### Task 2: 미사용 UIKit 근무 등록 코드 제거

`Presentation/WorkRegister/`와 `Coordinator/WorkRegister/`는 폴더 밖에서 참조하는 곳이 하나도 없다. #112에서 진입점이 SwiftUI로 옮겨간 뒤 `WorkRegisterCoordinator`를 인스턴스화하는 코드가 사라져 완전히 죽었다.

**Files:**
- Delete: `MOUP/MOUP/Presentation/WorkRegister/` 전체 (27 swift 파일 / 4,527줄)
- Delete: `MOUP/MOUP/Coordinator/WorkRegister/` 전체 (2 swift 파일 / 151줄)

**Interfaces:**
- Consumes: 없음
- Produces: 없음 (순수 삭제)

- [ ] **Step 1: 삭제 전 고립 여부 재확인**

```bash
cd MOUP/MOUP
for f in $(find Presentation/WorkRegister Coordinator/WorkRegister -name "*.swift" -exec basename {} .swift \;); do
  grep -rln "\b$f\b" --include="*.swift" . \
    | grep -v "^./Presentation/WorkRegister/" \
    | grep -v "^./Coordinator/WorkRegister/"
done | sort -u
```

Expected: `./Presentation/InputForm/WorkRegister/WorkerWork/RoleSegmentedView.swift` 한 줄만 나온다. 이건 주석 문장(`OLDRoleSegmentedControl`의 SwiftUI 버전이다)이지 코드 참조가 아니다. 아래로 확인한다:

```bash
grep -n "OLDRoleSegmentedControl" MOUP/MOUP/Presentation/InputForm/WorkRegister/WorkerWork/RoleSegmentedView.swift
```

Expected: `///`로 시작하는 주석 줄 하나.

다른 파일이 나오면 **멈추고 보고한다.** 그 파일이 살아있는 참조를 갖고 있다는 뜻이다.

- [ ] **Step 2: 삭제**

```bash
cd /Users/macmillan/Projects/XcodeProjects/5rganization/MOUP/MOUP-iOS
git rm -r MOUP/MOUP/Presentation/WorkRegister MOUP/MOUP/Coordinator/WorkRegister
```

- [ ] **Step 3: 빌드**

Run: 위 "빌드 명령"
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: 시뮬레이터 확인**

앱을 실행해 캘린더 → 근무 등록/수정이 정상 동작하는지 본다. 죽은 코드를 지운 것이므로 동작 변화가 없어야 한다.

- [ ] **Step 5: 커밋**

```bash
git add -A MOUP/ docs/superpowers/plans/2026-08-27-workplace-register-swiftui.md
git commit -m "chore: #113 - 미사용 UIKit 근무 등록 코드 제거"
```

---

### Task 3: `WorkplaceForm` 상태 모델 구현

세 루트 화면이 공유할 값 타입을 먼저 만든다. 뷰가 없으므로 이 태스크의 검증은 빌드 통과까지다.

**Files:**
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/WorkplaceForm.swift`

**Interfaces:**
- Consumes: `LabelColor`(`Presentation/Utils/Enums/LabelColor.swift`), `WorkplaceCategory`(`Presentation/Utils/Enums/WorkplaceCategory.swift`), `SalaryType`·`SalaryCalculation`(`Domain/Entities/Salary/`), `WorkplaceCreateRequestDTO`·`SalaryCreateRequest`·`OwnerWorkplaceCreateRequestDTO`·`WorkplaceJoinRequestDTO`·`SalaryJoinCreateRequest`·`UpdateWorkplaceRequestDTO`·`SalaryUpdateRequestDTO`(`Data/DTO/Request/`), `WorkplaceDetailResponseDTO`(`Data/DTO/Response/`)
- Produces: `struct WorkplaceForm: Equatable`. 저장 프로퍼티 `workplaceName`, `category`, `labelColor`, `salaryType`, `salaryCalculation`, `salaryAmount`, `payDay`, `hasNationalPension`, `hasHealthInsurance`, `hasEmploymentInsurance`, `hasIndustrialAccident`, `hasIncomeTax`, `hasHolidayAllowance`, `hasNightAllowance`. 계산 프로퍼티 `hasAllMajorInsurances`, `formattedSalaryAmount`, `formattedPayDay`, `isWorkerValid`, `isOwnerValid`, `isJoinValid`. 메서드 `setAllMajorInsurances(_:)`. DTO 프로퍼티 `createRequestDTO`, `ownerCreateRequestDTO`, `updateRequestDTO`, `joinRequestDTO(inviteCode:)`. 이니셜라이저 `init()`, `init(detail:)`

- [ ] **Step 1: `WorkplaceForm.swift` 생성**

```swift
//
//  WorkplaceForm.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import Foundation

/// 근무지 등록/수정 폼의 상태를 담는 값 타입
///
/// 알바생 직접 등록, 사장님 등록, 초대코드 참여 세 화면이 같은 필드 집합의 부분집합을 쓴다.
/// View에서는 `@State private var form = WorkplaceForm()`으로 선언해 사용한다.
struct WorkplaceForm: Equatable {

    // MARK: - Properties

    var workplaceName: String
    var category: WorkplaceCategory?
    var labelColor: LabelColor

    var salaryType: SalaryType?
    var salaryCalculation: SalaryCalculation?
    /// 시급 또는 고정급 금액. 계산 방식에 따라 `hourlyRate`/`fixedRate` 중 하나로 전송된다.
    var salaryAmount: Int
    /// 급여일(일). 서버의 `salaryDate`.
    var payDay: Int

    var hasNationalPension: Bool
    var hasHealthInsurance: Bool
    var hasEmploymentInsurance: Bool
    var hasIndustrialAccident: Bool
    var hasIncomeTax: Bool
    var hasHolidayAllowance: Bool
    var hasNightAllowance: Bool

    // MARK: - Initializer

    /// 등록 모드: 기본값으로 초기화
    init() {
        self.workplaceName = ""
        self.category = nil
        self.labelColor = ._default
        self.salaryType = nil
        self.salaryCalculation = nil
        self.salaryAmount = 0
        self.payDay = 1
        self.hasNationalPension = false
        self.hasHealthInsurance = false
        self.hasEmploymentInsurance = false
        self.hasIndustrialAccident = false
        self.hasIncomeTax = false
        self.hasHolidayAllowance = false
        self.hasNightAllowance = false
    }

    /// 수정 모드: 상세 응답으로부터 초기화
    ///
    /// 색상 키가 역할에 따라 다르다. 알바생은 `workerBasedLabelColor`, 사장님은 `ownerBasedLabelColor`에만 값이 온다.
    /// 급여 정보(`salaryDetailInfo`)는 알바생일 때만 존재한다.
    init(detail: WorkplaceDetailResponseDTO) {
        self.init()

        self.workplaceName = detail.workplaceName
        self.category = WorkplaceCategory(serverStr: detail.categoryName)

        let colorStr = detail.workerBasedLabelColor ?? detail.ownerBasedLabelColor
        self.labelColor = colorStr.flatMap { LabelColor(serverStr: $0) } ?? ._default

        guard let salary = detail.salaryDetailInfo else { return }

        self.salaryType = SalaryType(serverValue: salary.salaryType)
        self.salaryCalculation = SalaryCalculation(serverValue: salary.salaryCalculation)
        self.salaryAmount = salary.hourlyRate ?? 0
        self.payDay = salary.salaryDate ?? 1
        self.hasNationalPension = salary.hasNationalPension ?? false
        self.hasHealthInsurance = salary.hasHealthInsurance ?? false
        self.hasEmploymentInsurance = salary.hasEmploymentInsurance ?? false
        self.hasIndustrialAccident = salary.hasIndustrialAccident ?? false
        self.hasIncomeTax = salary.hasIncomeTax ?? false
        self.hasHolidayAllowance = salary.hasHolidayAllowance ?? false
        self.hasNightAllowance = salary.hasNightAllowance ?? false
    }
}

// MARK: - 4대 보험

extension WorkplaceForm {

    /// "4대 보험" 마스터 체크박스의 표시 상태
    ///
    /// 별도 필드로 저장하지 않는다. 하위 4개가 모두 켜졌는지의 파생 값이다.
    var hasAllMajorInsurances: Bool {
        hasNationalPension && hasHealthInsurance && hasEmploymentInsurance && hasIndustrialAccident
    }

    /// "4대 보험" 마스터 체크박스를 탭했을 때 하위 4개를 일괄 설정한다.
    mutating func setAllMajorInsurances(_ isOn: Bool) {
        hasNationalPension = isOn
        hasHealthInsurance = isOn
        hasEmploymentInsurance = isOn
        hasIndustrialAccident = isOn
    }
}

// MARK: - 표시용 파생 값

extension WorkplaceForm {

    var formattedSalaryAmount: String {
        salaryAmount == 0 ? "선택" : NumberFormatter.formattedWon(from: salaryAmount)
    }

    var formattedPayDay: String {
        "\(payDay)일"
    }
}

// MARK: - 유효성

extension WorkplaceForm {

    /// 알바생 직접 등록/수정: 근무지 · 급여가 모두 필요하다.
    var isWorkerValid: Bool {
        !workplaceName.isEmpty
            && category != nil
            && salaryType != nil
            && salaryCalculation != nil
            && salaryAmount > 0
    }

    /// 사장님 등록/수정: 근무지 정보만 받는다.
    var isOwnerValid: Bool {
        !workplaceName.isEmpty && category != nil
    }

    /// 초대코드 참여: 이름·카테고리는 초대코드가 결정하므로 검사하지 않는다.
    var isJoinValid: Bool {
        salaryType != nil && salaryCalculation != nil && salaryAmount > 0
    }
}

// MARK: - DTO 변환

extension WorkplaceForm {

    /// 시급제면 `hourlyRate`에, 고정급이면 `fixedRate`에 금액이 들어간다.
    private var isHourly: Bool {
        salaryCalculation == .hourly
    }

    /// 알바생 직접 등록 요청 DTO
    ///
    /// 주소·좌표는 화면에 입력 수단이 없어 기존 UIKit 구현과 동일한 더미값을 보낸다.
    var createRequestDTO: WorkplaceCreateRequestDTO {
        WorkplaceCreateRequestDTO(
            workplaceName: workplaceName,
            categoryName: (category ?? .others).serverStr,
            address: "기본 주소",
            latitude: 0.0,
            longitude: 0.0,
            workerBasedLabelColor: labelColor.serverStr,
            salaryCreateRequest: salaryCreateRequest
        )
    }

    /// 사장님 등록 요청 DTO
    ///
    /// 색상 키가 알바생과 다르다. 사장님은 `ownerBasedLabelColor`다.
    var ownerCreateRequestDTO: OwnerWorkplaceCreateRequestDTO {
        OwnerWorkplaceCreateRequestDTO(
            workplaceName: workplaceName,
            categoryName: (category ?? .others).serverStr,
            ownerBasedLabelColor: labelColor.serverStr
        )
    }

    /// 근무지 수정 요청 DTO (알바생·사장님 공용)
    var updateRequestDTO: UpdateWorkplaceRequestDTO {
        UpdateWorkplaceRequestDTO(
            workplaceName: workplaceName,
            categoryName: (category ?? .others).serverStr,
            address: "기본 주소",
            latitude: 0.0,
            longitude: 0.0,
            workerBasedLabelColor: labelColor.serverStr,
            salaryUpdateRequest: SalaryUpdateRequestDTO(
                salaryType: (salaryType ?? .monthly).serverValue,
                salaryCalculation: (salaryCalculation ?? .hourly).serverValue,
                hourlyRate: salaryAmount,
                salaryDate: payDay,
                hasNationalPension: hasNationalPension,
                hasHealthInsurance: hasHealthInsurance,
                hasEmploymentInsurance: hasEmploymentInsurance,
                hasIndustrialAccident: hasIndustrialAccident,
                hasIncomeTax: hasIncomeTax,
                hasHolidayAllowance: hasHolidayAllowance,
                hasNightAllowance: hasNightAllowance
            )
        )
    }

    /// 초대코드 참여 요청 DTO
    ///
    /// 참여 전용 DTO만 `fixedRate`·`salaryDay`를 갖는다. 직접 등록용 `SalaryCreateRequest`에는 없다.
    /// `salaryDay`는 화면에 입력 수단이 없어 기존 UIKit 구현과 동일하게 `"MONDAY"`를 보낸다.
    func joinRequestDTO(inviteCode: String) -> WorkplaceJoinRequestDTO {
        WorkplaceJoinRequestDTO(
            inviteCode: inviteCode,
            workerBasedLabelColor: labelColor.serverStr,
            salaryCreateRequest: SalaryJoinCreateRequest(
                salaryType: (salaryType ?? .monthly).serverValue,
                salaryCalculation: (salaryCalculation ?? .hourly).serverValue,
                hourlyRate: isHourly ? salaryAmount : nil,
                fixedRate: isHourly ? nil : salaryAmount,
                salaryDate: payDay,
                salaryDay: "MONDAY",
                hasNationalPension: hasNationalPension,
                hasHealthInsurance: hasHealthInsurance,
                hasEmploymentInsurance: hasEmploymentInsurance,
                hasIndustrialAccident: hasIndustrialAccident,
                hasIncomeTax: hasIncomeTax,
                hasHolidayAllowance: hasHolidayAllowance,
                hasNightAllowance: hasNightAllowance
            )
        )
    }

    private var salaryCreateRequest: SalaryCreateRequest {
        SalaryCreateRequest(
            salaryType: (salaryType ?? .monthly).serverValue,
            salaryCalculation: (salaryCalculation ?? .hourly).serverValue,
            hourlyRate: salaryAmount,
            salaryDate: payDay,
            hasNationalPension: hasNationalPension,
            hasHealthInsurance: hasHealthInsurance,
            hasEmploymentInsurance: hasEmploymentInsurance,
            hasIndustrialAccident: hasIndustrialAccident,
            hasIncomeTax: hasIncomeTax,
            hasHolidayAllowance: hasHolidayAllowance,
            hasNightAllowance: hasNightAllowance
        )
    }
}
```

- [ ] **Step 2: 의존 심볼 존재 확인**

계획 작성 시점에 확인하지 못한 것들이다. 없으면 만들지 말고 **실제 이름을 찾아 코드를 맞춘다.**

```bash
cd MOUP/MOUP
grep -n "init?(serverStr" Presentation/Utils/Enums/WorkplaceCategory.swift
grep -n "formattedWon" Common/Utils/Extensions/*.swift Presentation/Utils/**/*.swift 2>/dev/null
grep -n "struct UpdateWorkplaceRequestDTO" -A 12 Data/DTO/Request/UpdateWorkplaceRequestDTO.swift
grep -n "struct SalaryUpdateRequestDTO" -A 15 Data/DTO/Request/SalaryUpdateRequestDTO.swift
```

- `WorkplaceCategory`에 `init?(serverStr:)`가 없으면 `LabelColor`와 같은 형태로 추가한다 (`allCases.first(where:)` 방식)
- `NumberFormatter.formattedWon(from:)`이 없으면 `WizardTextFieldView.swift`의 문서 주석이 쓰는 이름을 따라 확인하고, 없으면 `Common/Utils/Extensions/`에 추가한다

- [ ] **Step 3: 빌드**

Run: 위 "빌드 명령"
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: 커밋**

```bash
git add MOUP/ docs/superpowers/plans/2026-08-27-workplace-register-swiftui.md
git commit -m "feat: #113 - 근무지 폼 상태 모델 구현"
```

---

### Task 4: 섹션 뷰 4개와 위저드 화면 7개 구현

루트 뷰가 조합할 부품들이다. 아직 루트가 없으므로 검증은 빌드 + SwiftUI Preview까지다.

**참조 파일** — 스타일과 레이아웃은 아래를 그대로 따른다. 새로 발명하지 않는다.
- 섹션 구성: `MOUP/MOUP/Presentation/InputForm/WorkRegister/MyWork/MyWorkFormView.swift:95-135` (`ContainerView` + `LabelChevronRowView` 조합)
- 위저드 화면: `MOUP/MOUP/Presentation/InputForm/WorkRegister/WorkplaceSelectView.swift` (하위 push 화면의 네비바·레이아웃 패턴)
- 기존 UIKit 문구: `MOUP/MOUP/Presentation/WorkplaceRegister/View/` 아래 대응 파일

**Files:**
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/Sections/WorkplaceSection.swift`
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/Sections/PaySection.swift`
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/Sections/WorkingConditionsSection.swift`
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/Sections/ColorLabelSection.swift`
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/Wizard/NameInputView.swift`
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/Wizard/CategorySelectView.swift`
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/Wizard/PayTypeSelectView.swift`
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/Wizard/PayCalculationSelectView.swift`
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/Wizard/SalaryInputView.swift`
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/Wizard/ColorLabelSelectView.swift`
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/Wizard/PayDayPickerSheet.swift`

**Interfaces:**
- Consumes: Task 3의 `WorkplaceForm` 전체. 기존 컴포넌트 `ContainerView(title:isRequired:content:)`, `LabelChevronRowView(leftColor:titleLabel:rightLabel:action:)`, `CheckBoxRow(title:isChecked:showInfo:onInfoTap:)`, `RadioButtonView(unselectedLeftImage:selectedLeftImage:label:isSelected:action:)`, `WizardTextFieldView(placeholder:text:keyboardType:regexStr:)`, `BaseNavigationBarSU(title:rightTitle:onBackTap:onRightTap:)`, `BaseButtonSU(title:isSecondary:fontSize:action:)`
- Produces:
  - `WorkplaceSection(form: Binding<WorkplaceForm>, onNameTap: () -> Void, onCategoryTap: () -> Void)`
  - `PaySection(form: Binding<WorkplaceForm>, onPayTypeTap: () -> Void, onPayCalculationTap: () -> Void, onSalaryTap: () -> Void, onPayDayTap: () -> Void)`
  - `WorkingConditionsSection(form: Binding<WorkplaceForm>, onInfoTap: (String) -> Void)`
  - `ColorLabelSection(form: Binding<WorkplaceForm>, onTap: () -> Void)`
  - `NameInputView(workplaceName: Binding<String>)`
  - `CategorySelectView(category: Binding<WorkplaceCategory?>)`
  - `PayTypeSelectView(salaryType: Binding<SalaryType?>)`
  - `PayCalculationSelectView(salaryCalculation: Binding<SalaryCalculation?>)`
  - `SalaryInputView(salaryAmount: Binding<Int>, salaryCalculation: SalaryCalculation?)`
  - `ColorLabelSelectView(labelColor: Binding<LabelColor>)`
  - `PayDayPickerSheet(payDay: Binding<Int>, isPresented: Binding<Bool>)`

- [ ] **Step 1: 섹션 뷰 4개 작성**

각 섹션은 `ContainerView`로 감싸고 행은 `LabelChevronRowView`를 쓴다. 제목과 행 라벨은 기존 UIKit과 동일하게 맞춘다.

```swift
// WorkplaceSection.swift
struct WorkplaceSection: View {
    @Binding var form: WorkplaceForm
    let onNameTap: () -> Void
    let onCategoryTap: () -> Void

    var body: some View {
        ContainerView(title: "근무지", isRequired: true) {
            LabelChevronRowView(titleLabel: "이름",
                                rightLabel: form.workplaceName.isEmpty ? "입력" : form.workplaceName,
                                action: onNameTap)
            LabelChevronRowView(titleLabel: "카테고리",
                                rightLabel: form.category?.displayStr ?? "선택",
                                action: onCategoryTap)
        }
    }
}
```

`PaySection`은 행 4개다. 라벨은 기존 UIKit(`Presentation/WorkplaceRegister/View/PayContainer/PayContainerView.swift:17-26`)과 동일하게 **"급여 유형"**(`form.salaryType?.displayText ?? "선택"`), **"급여 계산"**(`form.salaryCalculation?.displayStr ?? "선택"`), **"급여 형태"**(`form.formattedSalaryAmount`), **"급여일"**(`form.formattedPayDay`)로 둔다.

`WorkingConditionsSection`은 `CheckBoxRow` 8개다. **먼저 기존 UIKit에 4대 보험 안내 모달이 있는지 확인하고, 그 결과로 `onInfoTap` 파라미터의 유무를 여기서 확정한다.** Task 5는 이 결정을 따르기만 한다.

```bash
grep -rn "presentNoticeModal\|NoticeModal\|infoButton\|infoRow" \
  MOUP/MOUP/Presentation/WorkplaceRegister/ViewController/WorkingConditionsContainer/WorkingConditionsContainerViewController.swift \
  MOUP/MOUP/Presentation/WorkplaceRegister/View/WorkingConditionsContainer/WorkingConditionsContainerView.swift
```

- 안내 모달이 **있으면** `onInfoTap: (String) -> Void`를 파라미터로 두고, 안내를 띄우는 행만 `showInfo: true`로 한다
- **없으면** `onInfoTap` 파라미터를 만들지 않고 모든 행을 `showInfo: false`로 둔다. 이 경우 Task 5·7의 `WorkingConditionsSection(form:onInfoTap:)` 호출도 `WorkingConditionsSection(form:)`이 된다
 순서와 문구는 `Presentation/WorkplaceRegister/View/WorkingConditionsContainer/WorkingConditionsContainerView.swift:16-33`과 동일하게 "4대 보험", "국민연금", "건강보험", "고용보험", "산재보험", "소득세", "주휴수당", "야간수당". 마스터 행은 저장 필드가 없으므로 커스텀 바인딩을 쓴다:

```swift
CheckBoxRow(
    title: "4대 보험",
    isChecked: Binding(
        get: { form.hasAllMajorInsurances },
        set: { form.setAllMajorInsurances($0) }
    ),
    showInfo: true,
    onInfoTap: { onInfoTap("4대 보험") }
)
```

`ColorLabelSection`은 행 하나다. `LabelChevronRowView(leftColor: form.labelColor.labelColor, titleLabel: form.labelColor.displayStr, action: onTap)`.

- [ ] **Step 2: 라디오 선택 위저드 4개 작성**

`CategorySelectView`, `PayTypeSelectView`, `PayCalculationSelectView`, `ColorLabelSelectView`는 구조가 같다. 선택 즉시 `dismiss()`로 돌아간다.

```swift
// CategorySelectView.swift
struct CategorySelectView: View {
    @Binding var category: WorkplaceCategory?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            BaseNavigationBarSU(title: "카테고리 선택", onBackTap: { dismiss() })

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(WorkplaceCategory.allCases, id: \.self) { item in
                        RadioButtonView(label: item.displayStr,
                                        isSelected: category == item) {
                            category = item
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(.primaryBackground)
    }
}
```

- **`SalaryType`과 `SalaryCalculation`은 `CaseIterable`을 채택하지 않았다.** 두 선언을 `enum SalaryType: CaseIterable`, `enum SalaryCalculation: CaseIterable`로 바꾼다 (`Domain/Entities/Salary/`). `LabelColor`와 `WorkplaceCategory`는 이미 `CaseIterable`이다. 연관값 없는 enum이라 `Hashable`은 자동 합성되므로 따로 선언하지 않는다
- `ColorLabelSelectView`는 `LabelColor.allCases`에서 **`._default`를 제외**한다. 기존 UIKit이 7색(red·orange·yellow·green·blue·indigo·purple)만 노출한다
- `CategorySelectView`의 좌측 아이콘은 기존 UIKit(`SelectCategoryView.swift:25-49`)이 카테고리별 선택/미선택 이미지를 쓴다. 같은 에셋 이름을 `unselectedLeftImage`/`selectedLeftImage`로 넘긴다

- [ ] **Step 3: 텍스트 입력 위저드 2개 작성**

`NameInputView`는 `WizardTextFieldView(placeholder: "근무지 이름", text: $workplaceName)` + 하단 `BaseButtonSU(title: "확인")`으로 `dismiss()`.

`SalaryInputView`는 금액 포매팅 바인딩을 쓴다. placeholder는 기존과 같이 `"10,030원"`:

```swift
WizardTextFieldView(
    placeholder: "10,030원",
    text: Binding<String>(
        get: { salaryAmount == 0 ? "" : NumberFormatter.formattedWon(from: salaryAmount) },
        set: { salaryAmount = Int($0.filter { $0.isNumber }) ?? 0 }
    ),
    keyboardType: .numberPad
)
```

화면 제목은 `salaryCalculation`에 따라 바꾼다 — 시급이면 "시급 입력", 고정급이면 "고정급 입력".

- [ ] **Step 4: `PayDayPickerSheet` 작성**

1~31일 `Picker`를 `.wheel` 스타일로 띄운다. `Presentation/InputForm/Components/BreakTimePickerModal.swift`의 시트 레이아웃(그래버 + 확인 버튼)을 그대로 따른다.

- [ ] **Step 5: Preview 추가**

각 파일에 `#Preview`를 넣어 Xcode Canvas로 렌더링을 확인한다. 섹션 뷰는 `@Previewable`을 쓸 수 없으므로(iOS 16) `.constant(WorkplaceForm())` 대신 래퍼 뷰를 쓰거나 `ContainerView`의 Preview 방식을 따른다.

- [ ] **Step 6: 빌드**

Run: 위 "빌드 명령"
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 7: 커밋**

```bash
git add MOUP/ docs/superpowers/plans/2026-08-27-workplace-register-swiftui.md
git commit -m "feat: #113 - 근무지 폼 섹션 및 위저드 화면 구현"
```

---

### Task 5: 알바생 직접 등록/수정 루트와 Coordinator 배선

처음으로 시뮬레이터에서 돌려볼 수 있는 태스크다.

**Files:**
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/WorkplaceRegisterView.swift`
- Modify: `MOUP/MOUP/Coordinator/WorkplaceRegister/WorkplaceRegisterCoordinator.swift`

**Interfaces:**
- Consumes: Task 3의 `WorkplaceForm`, Task 4의 섹션·위저드 전부, `WorkplaceUseCaseProtocol`의 `createWorkplace(request:)`, `updateWorkplace(workplaceId:request:)`, `fetchWorkplaceDetail(workplaceId:)`
- Produces: `WorkplaceRegisterView(navigationController:mode:workplaceUseCase:onSaved:)` — `navigationController`와 `onSaved`는 기본값 `nil`. `enum WorkplaceRegisterView.Mode { case create, edit(workplaceId: Int) }`

- [ ] **Step 1: `WorkplaceRegisterView` 작성**

`MOUP/MOUP/Presentation/InputForm/WorkRegister/WorkerWorkRegisterView.swift:64-115`와 `MyWork/MyWorkFormView.swift:95-200`을 합친 형태다. 이 화면은 잠금/편집 토글이 없으므로 `isEditing`·`hasChanges`·`originalForm`은 두지 않는다.

```swift
struct WorkplaceRegisterView: View {

    enum Mode {
        case create
        case edit(workplaceId: Int)
    }

    private let navigationController: UINavigationController?
    private let mode: Mode
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let onSaved: ((Int) -> Void)?

    @State private var form = WorkplaceForm()
    @State private var isLoaded = false
    @State private var isSaving = false

    @State private var showNameInput = false
    @State private var showCategorySelect = false
    @State private var showPayTypeSelect = false
    @State private var showPayCalculationSelect = false
    @State private var showSalaryInput = false
    @State private var showColorLabelSelect = false
    @State private var isPayDayPickerPresented = false

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "WorkplaceRegisterView")

    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BaseNavigationBarSU(
                    title: isEditMode ? "근무지 수정" : "새 근무지 등록",
                    onBackTap: { navigationController?.popViewController(animated: true) }
                )

                ScrollView {
                    VStack(spacing: 24) {
                        WorkplaceSection(form: $form,
                                         onNameTap: { showNameInput = true },
                                         onCategoryTap: { showCategorySelect = true })
                        PaySection(form: $form,
                                   onPayTypeTap: { showPayTypeSelect = true },
                                   onPayCalculationTap: { showPayCalculationSelect = true },
                                   onSalaryTap: { showSalaryInput = true },
                                   onPayDayTap: { isPayDayPickerPresented = true })
                        WorkingConditionsSection(form: $form, onInfoTap: presentInsuranceNotice)
                        ColorLabelSection(form: $form, onTap: { showColorLabelSelect = true })
                    }
                    .padding(.top, 20)

                    Spacer().frame(height: 60)

                    BaseButtonSU(title: isEditMode ? "수정하기" : "등록하기") {
                        Task { await save() }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .disabled(!form.isWorkerValid || isSaving)

                    Spacer().frame(height: UIApplication.safeAreaBottom + 12)
                }
                .scrollDismissesKeyboard(.interactively)
                .ignoresSafeArea(edges: .bottom)
            }
            .toolbar(.hidden, for: .navigationBar)
            .task { await loadDetailIfNeeded() }
            .navigationDestination(isPresented: $showNameInput) {
                NameInputView(workplaceName: $form.workplaceName)
            }
            .navigationDestination(isPresented: $showCategorySelect) {
                CategorySelectView(category: $form.category)
            }
            .navigationDestination(isPresented: $showPayTypeSelect) {
                PayTypeSelectView(salaryType: $form.salaryType)
            }
            .navigationDestination(isPresented: $showPayCalculationSelect) {
                PayCalculationSelectView(salaryCalculation: $form.salaryCalculation)
            }
            .navigationDestination(isPresented: $showSalaryInput) {
                SalaryInputView(salaryAmount: $form.salaryAmount,
                                salaryCalculation: form.salaryCalculation)
            }
            .navigationDestination(isPresented: $showColorLabelSelect) {
                ColorLabelSelectView(labelColor: $form.labelColor)
            }
            .sheet(isPresented: $isPayDayPickerPresented) {
                PayDayPickerSheet(payDay: $form.payDay, isPresented: $isPayDayPickerPresented)
            }
            .background(.primaryBackground)
        }
        .background(
            // 상위 UIKit 네비게이션의 스와이프 백 제스처를 복원하기 위해 유지한다.
            NavigationControllerFinder { _ in }
                .frame(width: 0, height: 0)
        )
    }
}
```

- [ ] **Step 2: 비동기 메서드 작성**

`MyWorkFormView`와 같이 익스텐션 전체를 메인 액터에 묶는다. `View.body`만 `@MainActor`라 그러지 않으면 `@State`와 UIKit을 메인 스레드 밖에서 건드린다.

```swift
@MainActor private extension WorkplaceRegisterView {

    func presentNotice(title: String, comment: String, onConfirm: (() -> Void)? = nil) {
        navigationController?.presentNoticeModal(title: title, comment: comment, onConfirm: onConfirm)
    }

    /// `.task`는 하위 화면에서 복귀할 때도 다시 실행되므로, 이미 조회했으면 건너뛴다.
    /// 그렇지 않으면 위저드에서 고른 값이 서버 값으로 덮어써진다.
    func loadDetailIfNeeded() async {
        guard case .edit(let workplaceId) = mode, !isLoaded else { return }

        do {
            form = WorkplaceForm(detail: try await workplaceUseCase.fetchWorkplaceDetail(workplaceId: workplaceId))
            isLoaded = true
        } catch {
            logger.error("근무지 상세 조회 실패: \(error.localizedDescription)")
            presentNotice(title: "데이터 불러오기 실패",
                          comment: "근무지 정보를 불러오지 못했습니다.\n다시 시도해주세요.",
                          onConfirm: { navigationController?.popViewController(animated: true) })
        }
    }

    func save() async {
        isSaving = true
        defer { isSaving = false }

        do {
            switch mode {
            case .create:
                let result = try await workplaceUseCase.createWorkplace(request: form.createRequestDTO)
                onSaved?(result.workplaceId)
            case .edit(let workplaceId):
                try await workplaceUseCase.updateWorkplace(workplaceId: workplaceId,
                                                           request: form.updateRequestDTO)
                onSaved?(workplaceId)
            }
            navigationController?.popViewController(animated: true)
        } catch {
            logger.error("근무지 저장 실패: \(error.localizedDescription)")
            presentNotice(title: "저장 실패", comment: "근무지를 저장하지 못했습니다.\n다시 시도해주세요.")
        }
    }
}
```

**4대 보험 안내 모달 (`onInfoTap`)** — 문구를 지어내지 말고 기존 UIKit에서 찾아 그대로 옮긴다:

```bash
grep -rn "presentNoticeModal\|NoticeModal\|infoButton" \
  MOUP/MOUP/Presentation/WorkplaceRegister/ViewController/WorkingConditionsContainer/WorkingConditionsContainerViewController.swift \
  MOUP/MOUP/Presentation/WorkplaceRegister/View/WorkingConditionsContainer/WorkingConditionsContainerView.swift
```

- 안내 모달이 있으면 그 제목·본문을 그대로 쓰는 `presentInsuranceNotice(_ name: String)`를 익스텐션에 추가하고 `WorkingConditionsSection(form:onInfoTap:)`에 넘긴다
- 없으면 `onInfoTap`을 넘기지 말고 Task 4의 `CheckBoxRow`를 `showInfo: false`로 둔다. 이 경우 `WorkingConditionsSection`의 `onInfoTap` 파라미터도 지운다

**imports** — 이 파일은 `import OSLog`, `import SwiftUI`, `import UIKit`이 모두 필요하다. `MyWorkFormView.swift:8-10`과 동일하다.

- [ ] **Step 3: `WorkplaceRegisterCoordinator` 정리**

`lazy var` ViewModel 9개와 `show*()` 메서드 7개를 전부 삭제한다. `start()`만 남긴다.

```swift
final class WorkplaceRegisterCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    private let navigationController: UINavigationController
    private let isOwnerInjected: Bool
    private let registerMode: WorkplaceRegisterMode

    init(navigationController: UINavigationController, isOwner: Bool, mode: WorkplaceRegisterMode) {
        self.navigationController = navigationController
        self.isOwnerInjected = isOwner
        self.registerMode = mode
    }

    func start() {
        let useCase = WorkplaceUseCase(
            workplaceRepository: WorkplaceRepository(workplaceService: WorkplaceService())
        )

        let mode: WorkplaceRegisterView.Mode = {
            switch registerMode {
            case .create: return .create
            case .edit(let workplaceId): return .edit(workplaceId: workplaceId)
            }
        }()

        // 사장님 화면은 Task 6에서 붙인다. 그 전까지는 알바생 화면만 띄운다.
        let hostingVC = UIHostingController(
            rootView: WorkplaceRegisterView(navigationController: navigationController,
                                            mode: mode,
                                            workplaceUseCase: useCase)
        )
        hostingVC.hidesBottomBarWhenPushed = true
        navigationController.navigationBar.isHidden = true
        navigationController.pushViewController(hostingVC, animated: true)
    }
}
```

`WorkplaceRegisterMode`(`create`/`edit(workplaceId:)`)는 `WorkplaceRegisterViewModel.swift`에 정의돼 있고 그 파일은 Task 8에서 지운다. 지금은 그대로 둔다.

이 Coordinator 파일에 **`import SwiftUI`를 추가한다.** `UIHostingController`를 쓰려면 필요하다.

`WorkplaceRegisterCoordinatorProtocol` 채택을 `Coordinator`로 바꾼다. 프로토콜 파일 삭제는 Task 8에서 한다 (`InviteCodeInputCoordinator`가 아직 채택 중이다).

`init(navigationController:isOwner:mode:)` 시그니처는 바꾸지 않는다. 호출처 3곳(`HomeCoordinator.moveToDirectRegistration`, `HomeCoordinator.moveToEditWorkplace`, `WorkplaceRegisterSheetCoordinator.moveToDirectRegistration`)과 진입점 4곳(`HomeViewController` 3곳, `WorkplaceRegisterSheetViewController` 1곳)은 **수정하지 않는다.** 근무지 등록 진입 시트 자체는 UIKit 그대로 둔다.

- [ ] **Step 4: 빌드**

Run: 위 "빌드 명령"
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: 시뮬레이터 확인 (알바생 계정)**

1. 홈 → 근무지 추가 → 직접 등록 → 새 화면이 뜨는지
2. 위저드 6개(이름·카테고리·급여유형·급여계산·급여형태·색상) 각각 진입/선택/복귀 후 값이 행에 반영되는지
3. 급여일 시트가 뜨고 선택이 반영되는지
4. 필수 항목을 다 채우기 전에는 "등록하기"가 비활성인지
5. 등록 후 홈 목록에 새 근무지가 뜨는지
6. 홈에서 그 근무지 수정 진입 → 값이 프리필되는지 → 색상만 바꿔 저장 → 반영되는지
7. 스와이프 백 제스처가 동작하는지

- [ ] **Step 6: 커밋**

```bash
git add MOUP/ docs/superpowers/plans/2026-08-27-workplace-register-swiftui.md
git commit -m "feat: #113 - 알바생 근무지 등록/수정 화면 SwiftUI 재구현"
```

---

### Task 6: 사장님 등록/수정 루트

**Files:**
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/OwnerWorkplaceRegisterView.swift`
- Modify: `MOUP/MOUP/Coordinator/WorkplaceRegister/WorkplaceRegisterCoordinator.swift`

**Interfaces:**
- Consumes: Task 3의 `WorkplaceForm`(`ownerCreateRequestDTO`, `updateRequestDTO`, `isOwnerValid`), Task 4의 `WorkplaceSection`·`ColorLabelSection`·`NameInputView`·`CategorySelectView`·`ColorLabelSelectView`, `WorkplaceUseCaseProtocol.createOwnerWorkplace(request:)`
- Produces: `OwnerWorkplaceRegisterView(navigationController:mode:workplaceUseCase:onSaved:)` — `navigationController`와 `onSaved`는 기본값 `nil`. `typealias Mode = WorkplaceRegisterView.Mode`

- [ ] **Step 1: `OwnerWorkplaceRegisterView` 작성**

Task 5의 `WorkplaceRegisterView`와 같은 구조에서 섹션을 2개(`WorkplaceSection`, `ColorLabelSection`)로 줄이고, 위저드도 3개(`NameInputView`, `CategorySelectView`, `ColorLabelSelectView`)만 둔다. `Mode`는 `typealias Mode = WorkplaceRegisterView.Mode`로 재사용한다.

저장 분기만 다르다:

```swift
switch mode {
case .create:
    let result = try await workplaceUseCase.createOwnerWorkplace(request: form.ownerCreateRequestDTO)
    onSaved?(result.workplaceId)
case .edit(let workplaceId):
    try await workplaceUseCase.updateWorkplace(workplaceId: workplaceId, request: form.updateRequestDTO)
    onSaved?(workplaceId)
}
```

완료 버튼 활성 조건은 `form.isOwnerValid`다.

- [ ] **Step 2: Coordinator에 사장님 분기 추가**

Task 5 Step 3의 `start()`에서 `isOwnerInjected`로 갈라 `UIHostingController`를 각각 만든다. `AnyView`로 감싸지 않는다.

`let hostingVC: UIHostingController<some View>` 형태는 쓰지 않는다 — `some View`는 서로 다른 두 타입에 바인딩되는 변수 타입으로 쓸 수 없어 컴파일되지 않는다. `CalendarCoordinator.showWorkerWorkRegister`/`showOwnerWorkRegister`처럼 **분기마다 push까지 하는 형태**로 쓴다:

```swift
func start() {
    let useCase = ...
    let mode: WorkplaceRegisterView.Mode = ...
    if isOwnerInjected {
        push(UIHostingController(rootView: OwnerWorkplaceRegisterView(...)))
    } else {
        push(UIHostingController(rootView: WorkplaceRegisterView(...)))
    }
}

private func push(_ vc: UIViewController) {
    vc.hidesBottomBarWhenPushed = true
    navigationController.navigationBar.isHidden = true
    navigationController.pushViewController(vc, animated: true)
}
```

- [ ] **Step 3: 빌드**

Run: 위 "빌드 명령"
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: 시뮬레이터 확인 (사장님 계정)**

1. 홈 → 근무지 추가 → 새 화면이 뜨고 급여·근무조건 섹션이 **없는지**
2. 이름·카테고리·색상 입력 후 등록 → 홈 목록 반영
3. 수정 진입 → 프리필 확인. 특히 **색상이 제대로 뜨는지** (사장님은 `ownerBasedLabelColor` 키로 온다)
4. 수정 저장 후 반영 확인

- [ ] **Step 5: 커밋**

```bash
git add MOUP/ docs/superpowers/plans/2026-08-27-workplace-register-swiftui.md
git commit -m "feat: #113 - 사장님 근무지 등록/수정 화면 SwiftUI 재구현"
```

---

### Task 7: 초대코드 참여 루트

**Files:**
- Create: `MOUP/MOUP/Presentation/InputForm/WorkplaceRegister/InviteCodeWorkplaceRegisterView.swift`
- Modify: `MOUP/MOUP/Coordinator/WorkplaceRegister/InviteCodeInputCoordinator.swift`

**Interfaces:**
- Consumes: Task 3의 `WorkplaceForm`(`joinRequestDTO(inviteCode:)`, `isJoinValid`), Task 4의 `PaySection`·`WorkingConditionsSection`·`ColorLabelSection`과 급여·색상 위저드 4개, `WorkplaceUseCaseProtocol.joinWorkplace(request:)`
- Produces: `InviteCodeWorkplaceRegisterView(navigationController:workplaceName:inviteCode:workplaceUseCase:onJoined:)` — `navigationController`와 `onJoined`는 기본값 `nil`

- [ ] **Step 1: `InviteCodeWorkplaceRegisterView` 작성**

등록 전용이라 `Mode`가 없다. 근무지 이름은 초대코드가 결정하므로 읽기 전용으로 보여준다.

```swift
struct InviteCodeWorkplaceRegisterView: View {

    private let navigationController: UINavigationController?
    private let workplaceName: String
    private let inviteCode: String
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let onJoined: (() -> Void)?

    @State private var form = WorkplaceForm()
    @State private var isSaving = false
    // 급여·색상 위저드 표시 플래그는 Task 5와 동일
```

`body`는 Task 5와 같은 뼈대에서 섹션을 `PaySection` → `WorkingConditionsSection` → `ColorLabelSection` 순으로 두고, 맨 위에 읽기 전용 근무지 이름을 놓는다. 기존 UIKit(`Presentation/Home/View/InviteCodeWorkplaceRegisterView.swift`)의 표시 방식을 그대로 따른다.

네비게이션 타이틀과 버튼 문구도 기존 UIKit에서 가져온다:
```bash
grep -n "BaseNavigationBar(title\|BaseButton(title" MOUP/MOUP/Presentation/Home/View/InviteCodeWorkplaceRegisterView.swift
```

저장은 하나뿐이다:

```swift
func join() async {
    isSaving = true
    defer { isSaving = false }

    do {
        _ = try await workplaceUseCase.joinWorkplace(request: form.joinRequestDTO(inviteCode: inviteCode))
        onJoined?()
        navigationController?.popToRootViewController(animated: true)
    } catch {
        logger.error("근무지 참여 실패: \(error.localizedDescription)")
        presentNotice(title: "참여 실패", comment: "근무지 참여에 실패했습니다.\n다시 시도해주세요.")
    }
}
```

복귀 방식(`popToRootViewController` vs `popViewController`)은 기존 UIKit이 참여 성공 후 어디로 가는지 확인해 맞춘다:
```bash
grep -n "didCompleteRegister" -A 10 MOUP/MOUP/Presentation/Home/ViewController/InviteCodeWorkplaceRegisterViewController.swift
```

- [ ] **Step 2: `InviteCodeInputCoordinator` 정리**

`lazy var` ViewModel 6개(`selectPayTypeVM`, `selectPayCalcVM`, `inputSalaryTypeVM`, `payDayPickerVM`, `workingConditionsVM`, `selectColorLabelVM`, `colorLabelVM`, `payVM`)를 전부 삭제한다.

`WorkplaceRegisterCoordinatorProtocol` 채택과 그 빈 구현 익스텐션(`showSelectCategory()` 등 7개가 `return`만 하는 것)을 삭제하고 `Coordinator`만 채택한다.

`moveToInviteCodeWorkplaceRegister`를 바꾼다:

```swift
func moveToInviteCodeWorkplaceRegister(workplaceName: String, inviteCode: String) {
    let hostingVC = UIHostingController(
        rootView: InviteCodeWorkplaceRegisterView(navigationController: navigationController,
                                                  workplaceName: workplaceName,
                                                  inviteCode: inviteCode,
                                                  workplaceUseCase: workplaceUseCase)
    )
    hostingVC.hidesBottomBarWhenPushed = true
    navigationController.pushViewController(hostingVC, animated: true)
}
```

`import UIKit`에 더해 `import SwiftUI`가 필요하다.

- [ ] **Step 3: 빌드**

Run: 위 "빌드 명령"
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: 시뮬레이터 확인 (알바생 계정)**

1. 홈 → 근무지 추가 → 초대코드 입력 → 코드 조회 → 결과 → 참여 화면 진입
2. 근무지 이름이 읽기 전용으로 뜨는지, 근무지 섹션(이름·카테고리 편집)이 **없는지**
3. 급여 계산을 **시급**으로 놓고 참여 → 네트워크 로그에서 `hourlyRate`만 채워지고 `fixedRate`가 `null`인지
4. 급여 계산을 **고정급**으로 놓고 참여 → 반대인지
5. 참여 성공 후 이동 화면이 기존과 같은지

- [ ] **Step 5: 커밋**

```bash
git add MOUP/ docs/superpowers/plans/2026-08-27-workplace-register-swiftui.md
git commit -m "feat: #113 - 초대코드 근무지 참여 화면 SwiftUI 재구현"
```

---

### Task 8: 구 UIKit 근무지 등록 코드 제거

세 루트가 모두 SwiftUI로 옮겨졌으므로 이제 구 코드를 지울 수 있다.

**Files:**
- Move: `MOUP/MOUP/Presentation/WorkplaceRegister/Utils/OLDCustomTextField.swift` → `MOUP/MOUP/Presentation/Utils/OLDCustomTextField.swift`
- Delete: `MOUP/MOUP/Presentation/WorkplaceRegister/` 나머지 전체 (44 swift 파일)
- Delete: `MOUP/MOUP/Presentation/Home/View/InviteCodeWorkplaceRegisterView.swift`
- Delete: `MOUP/MOUP/Presentation/Home/ViewController/InviteCodeWorkplaceRegisterViewController.swift`
- Delete: `MOUP/MOUP/Presentation/Home/ViewModel/InviteCodeWorkplaceRegisterViewModel.swift`
- Delete: `MOUP/MOUP/Coordinator/WorkplaceRegister/Protocol/WorkplaceRegisterCoordinatorProtocol.swift`
- Modify: `WorkplaceRegisterMode` 정의를 옮길 곳 (아래 Step 2)

**Interfaces:**
- Consumes: 없음
- Produces: 없음 (삭제 + 이동)

- [ ] **Step 1: `OLDCustomTextField` 이동**

`Routine/AddRoutineView`, `Routine/EditRoutineView`, `MyPage/EditModal`이 **현재 사용 중**이다. 지우면 안 된다.

```bash
cd /Users/macmillan/Projects/XcodeProjects/5rganization/MOUP/MOUP-iOS
git mv MOUP/MOUP/Presentation/WorkplaceRegister/Utils/OLDCustomTextField.swift \
       MOUP/MOUP/Presentation/Utils/OLDCustomTextField.swift
```

사용처를 재확인한다 (이동 후에도 같은 3곳이어야 한다):
```bash
grep -rln "OLDCustomTextField" --include="*.swift" MOUP/MOUP/Presentation/
```

- [ ] **Step 2: `WorkplaceRegisterMode` 옮기기**

`enum WorkplaceRegisterMode`가 삭제 대상인 `WorkplaceRegisterViewModel.swift` 안에 있고 `HomeCoordinator`·`WorkplaceRegisterCoordinator`가 쓴다.

```bash
grep -rn "WorkplaceRegisterMode" --include="*.swift" MOUP/MOUP/
```

`Coordinator/WorkplaceRegister/WorkplaceRegisterCoordinator.swift` 상단으로 정의를 옮긴다. 다른 곳에서도 쓰면 `Presentation/Utils/Enums/`로 옮긴다.

- [ ] **Step 3: 삭제**

```bash
git rm -r MOUP/MOUP/Presentation/WorkplaceRegister
git rm MOUP/MOUP/Presentation/Home/View/InviteCodeWorkplaceRegisterView.swift \
       MOUP/MOUP/Presentation/Home/ViewController/InviteCodeWorkplaceRegisterViewController.swift \
       MOUP/MOUP/Presentation/Home/ViewModel/InviteCodeWorkplaceRegisterViewModel.swift \
       MOUP/MOUP/Coordinator/WorkplaceRegister/Protocol/WorkplaceRegisterCoordinatorProtocol.swift
```

- [ ] **Step 4: 남은 참조 정리**

```bash
cd MOUP/MOUP
grep -rn "WorkplaceRegisterCoordinatorProtocol\|InviteCodeWorkplaceRegisterViewModel\|OLDInfoRowView\|OLDContainerView\|OLDRadioButtonView" --include="*.swift" .
```

Expected: 결과 없음. 나오면 그 파일을 고친다.

`InviteCodeResultViewController`가 `InviteCodeInputCoordinator`를 통해 참여 화면으로 가는 경로는 Task 7에서 이미 바꿨으므로 그대로 동작해야 한다.

- [ ] **Step 5: 빌드**

Run: 위 "빌드 명령"
Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 6: 시뮬레이터 전체 회귀**

알바생 계정으로 직접 등록 · 수정 · 초대코드 참여, 사장님 계정으로 등록 · 수정. Task 5·6·7의 확인 항목을 다시 한 번 훑는다. 추가로 루틴 추가/수정 화면과 마이페이지 닉네임 수정 모달(`OLDCustomTextField` 사용처)이 정상인지 본다.

- [ ] **Step 7: 커밋**

```bash
git add -A MOUP/ docs/superpowers/plans/2026-08-27-workplace-register-swiftui.md
git commit -m "chore: #113 - 구 UIKit 근무지 등록 코드 제거"
```

---

### Task 9: CLAUDE.md 갱신

**Files:**
- Modify: `CLAUDE.md`

**Interfaces:**
- Consumes: 없음
- Produces: 없음

- [ ] **Step 1: "OLD 접두사" 절 수정**

"31개 파일이 `OLD` 접두사를 달고 있다"는 문장이 더 이상 맞지 않는다. 실제 개수를 세어 고친다:

```bash
find MOUP/MOUP -name "OLD*.swift" | wc -l
```

- [ ] **Step 2: "진행 중인 작업" 절 수정**

`Presentation/WorkplaceRegister/`가 UIKit이라는 서술과 "이슈 #113 미착수", "`RadioButtonView`, `WizardTextFieldView`는 현재 사용처가 없다"를 지운다. 근무지 폼도 SwiftUI 재구현이 완료됐고 세 루트(`WorkplaceRegisterView`, `OwnerWorkplaceRegisterView`, `InviteCodeWorkplaceRegisterView`)가 `Presentation/InputForm/WorkplaceRegister/`에 있다는 내용으로 바꾼다.

- [ ] **Step 3: "UIKit + SwiftUI 과도기" 절의 수치 갱신**

"RxSwift 사용 172파일 vs SwiftUI 27파일"을 실제 값으로 고친다:

```bash
grep -rl "import RxSwift" --include="*.swift" MOUP/MOUP | wc -l
grep -rl "import SwiftUI" --include="*.swift" MOUP/MOUP | wc -l
```

- [ ] **Step 4: 커밋**

```bash
git add CLAUDE.md docs/superpowers/plans/2026-08-27-workplace-register-swiftui.md
git commit -m "chore: #113 - CLAUDE.md의 진행 중인 작업 절 갱신"
```

---

## 완료 후

`task/#113` → `task/#115`로 PR을 연다. 부모 이슈 #115의 하위 4개가 모두 닫히면 `task/#115` → `develop` PR을 다시 연다 (#120은 CLOSED 상태다).
