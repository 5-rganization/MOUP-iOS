# MOUP-iOS

알바생·사장님용 근무 관리 iOS 앱. Swift 5 / iOS 16+ / Xcode 16+.
서비스 소개, 기술적 의사결정, 트러블슈팅 기록은 [README.md](README.md) 참고 (여기에 중복 작성하지 않음).

## 빌드

**`MOUP/MOUP.xcworkspace`로 열 것.** `.xcodeproj`로 열면 CocoaPods 의존성(`JTAppleCalendar`)이 빠져 빌드 실패.

빌드·테스트의 기본 검증 기준은 **iPhone 13 mini / iOS 16.0**이다. 배포 최소 타깃이 iOS 16이므로 여기서 통과해야 한다.

```bash
cd MOUP && pod install     # Pods/ 없거나 Podfile.lock 변경 시
xcodebuild -workspace MOUP/MOUP.xcworkspace -scheme MOUP \
  -destination 'platform=iOS Simulator,name=iPhone 13 mini,OS=16.0' build
```

의존성은 SPM(Alamofire, RxSwift, SnapKit, Firebase, GoogleSignIn 등) + CocoaPods(JTAppleCalendar) 혼용.

### 클론 직후 빌드 불가 — gitignore된 설정 파일

아래 파일이 없으면 빌드가 깨진다. 팀 내부에서 별도 공유받아야 함.

- `GoogleConfig.xcconfig`, `NetworkConfig-Debug.xcconfig`, `NetworkConfig-Release.xcconfig` (리포 루트)
- `GoogleService-Info-Debug.plist`, `GoogleService-Info-Release.plist`, `credentials.plist`

앱 버전/빌드 번호는 Xcode 프로젝트 설정이 아니라 **`MOUP/MOUP/Resources/Version.xcconfig`**에서 관리.

## 아키텍처

Clean Architecture + MVVM + Coordinator. `MOUP/MOUP/` 아래 4계층:

```
App/            AppDelegate, SceneDelegate, AppCoordinator
Presentation/   View(Controller) + ViewModel, 기능별 폴더
Domain/         Entities, UseCases, Interfaces(Repository/UseCase 프로토콜)
Data/           Services, Repositories, DTO, Routers(Alamofire), Network
Coordinator/    화면 전환 담당. 기능 단위 Coordinator + Protocol/Coordinator.swift
```

- DI는 프레임워크 없이 **Coordinator가 손으로 조립**한다: `ViewModel(useCase: UseCase(repository: Repository(service: Service())))`. 새 화면 추가 시 해당 Coordinator에서 같은 방식으로 주입.
- 상위 계층은 `Domain/Interfaces`의 프로토콜에만 의존.
- 네트워크는 `URLRequestConvertible` Router 패턴 + `AuthInterceptor`(토큰 재발급) + async/await.

## 코드 컨벤션

- Swift 스타일: StyleShare Swift Style Guide.
- 커밋: `type: #이슈번호 - 한글 설명`. 쓰는 타입: `feat`, `fix`, `refactor`, `chore`, `rename`.
  - 설명은 **명사형 어미로 끝낼 것**: `~ 추가`, `~ 구현`, `~ 수정`, `~ 제거`, `~ 변경`.
  - 문장형(`~했습니다`, `~함`, `~하기`)이나 영어 동사형(`add ~`)은 쓰지 않는다.
  - 예: `feat: #112 - 알바생 근무 등록 화면 구현`, `fix: #112 - 네비게이션 바 숨김 코드 교체`
- 브랜치: `task/#이슈번호`, base는 `develop`.
- 커밋은 **빌드가 통과하는 단위로** 남긴다. 컴파일이 깨진 중간 상태를 커밋하지 않는다. 파일 여러 개를 함께 고쳐야 빌드가 되면 그 파일들을 한 커밋으로 묶는다.
- superpowers 플랜 문서를 따라 작업할 때는, 각 step이 끝나면 **플랜 문서의 체크박스를 체크한 것도 함께 커밋한다.** 코드 변경과 진행 상태가 같은 커밋에 남아야 어디까지 했는지 히스토리만 보고 알 수 있다.

## 작업 방식

라이브러리/API 문서 확인, 코드 생성, 설정 또는 구성 단계가 필요한 작업에서는 사용자가 명시적으로 요청하지 않아도 **항상 Context7 MCP를 먼저 사용해** 현재 문서와 권장 사용법을 확인한다.

Context7 MCP가 응답하지 않거나, 사용량 초과 등으로 사용할 수 없거나, 필요한 정보를 찾지 못해도 작업을 중단하지 않는다. 우선 기존 지식을 바탕으로 계속 진행하고, 기존 지식만으로 해결하기 어려울 때 공식 문서를 확인한다.

최종 응답에는 Context7을 사용하지 못한 이유와, 대체 출처를 확인했다면 실제로 확인한 출처를 명시한다.

## 주의할 점 (비자명)

### `OLD` 접두사 = 리팩토링 대상 레거시
`OLDWorkRegisterViewModel`, `OLDSelectedWorkplaceViewController` 등 31개 파일이 `OLD` 접두사를 달고 있다. **UIKit + RxSwift로 작성된 구버전이며 SwiftUI로 교체 중**이다.

- `OLD*` 파일은 유지보수만 하고 신규 기능을 얹지 말 것.
- 새 화면은 `Presentation/InputForm/` 아래 SwiftUI로 작성.

### UIKit + SwiftUI 과도기
RxSwift 사용 172파일 vs SwiftUI 27파일. 기존 화면은 전부 UIKit+Rx(`Input`/`Output` 구조체 + `transform()` + Relay 패턴)다.

SwiftUI 화면을 UIKit 네비게이션 스택에 얹을 때 **`UIHostingController`를 쓰지 않고** `Presentation/InputForm/Utils/NavigationControllerFinder.swift`(`UIViewControllerRepresentable` 브릿지)로 상위 `UINavigationController`를 찾아 쓴다. `.toolbar(.hidden, for: .navigationBar)`로 죽는 스와이프 백 제스처도 여기서 복원한다.

### `SU` 접미사 = 기존 UIKit 컴포넌트의 SwiftUI 래퍼
`BaseButtonSU`, `BaseNavigationBarSU`, `DatePickerViewSU`, `ModalGrabberViewSU` 등. 원본 UIKit 파일 옆에 `이름+SwiftUI.swift` 파일로 두고 `UIViewRepresentable` / `UIViewControllerRepresentable`로 감싼다. SwiftUI 화면에서 기존 컴포넌트가 필요하면 새로 만들지 말고 `SU` 래퍼가 있는지 먼저 확인할 것.

### 진행 중인 작업 (2026-03 기준)
근무 입력 폼의 SwiftUI 재구현이 진행 중이다. `Presentation/InputForm/` 아래 코드는 **아직 Coordinator에 연결되지 않았고 API 연동도 없다** (`MyWorkFormView`에 `// TODO: API 호출` 2건). `Presentation/WorkplaceRegister/`(근무지 등록/수정)는 아직 100% UIKit이며 SwiftUI 재구현 미착수.

## 테스트

테스트 타겟 없음. 검증은 시뮬레이터 실행으로 한다.
