//
//  NavigationControllerFinder.swift
//  MOUP
//
//  Created by 서동환 on 3/26/26.
//

import SwiftUI

/// UIKit의 `UINavigationController` 참조를 SwiftUI에서 획득하기 위한 브릿지 뷰.
///
/// SwiftUI 뷰 계층에서 가장 가까운 `UINavigationController`를 찾아 클로저로 전달하며,
/// `.toolbar(.hidden, for: .navigationBar)` 사용 시 비활성화되는 스와이프 백 제스처를 자동으로 복원합니다.
///
/// **어느 네비게이션을 찾는지는 이 뷰를 어디에 두느냐로 정해진다.** `vc.navigationController`는
/// 부모 VC를 거슬러 올라가므로, `NavigationStack { }` **바깥**(루트 폼의 `.background`)에 두면
/// 탭이 공유하는 바깥 UIKit 네비게이션을, `NavigationStack`이 push한 하위 화면 **안**에 두면
/// 그 스택 자신의 네비게이션을 찾는다.
///
/// 두 자리 모두 필요하다.
/// - 루트 폼: 바깥 스택의 `viewControllers.count`는 위저드를 push해도 그대로라, 위저드가 떠 있는
///   동안 `canPop: false`로 막지 않으면 스와이프가 위저드를 건너뛰고 홈까지 나가버린다.
/// - 위저드: `.toolbar(.hidden, for: .navigationBar)`이 스택 자신의 스와이프 백도 죽이므로,
///   `swipeBackEnabled()`로 되살려야 위저드에서 폼으로 스와이프해 돌아올 수 있다.
///
/// **사용 예시**
/// ```swift
/// struct SomeView: View {
///     @State private var navigationController: UINavigationController?
///     @State private var showWizard = false
///
///     var body: some View {
///         NavigationStack {
///             content
///                 .toolbar(.hidden, for: .navigationBar)
///         }
///         .background(
///             NavigationControllerFinder(canPop: !showWizard) { nav in
///                 navigationController = nav
///             }
///                 .frame(width: 0, height: 0)
///         )
///     }
/// }
/// ```
struct NavigationControllerFinder: UIViewControllerRepresentable {
    /// 바깥 UIKit 네비게이션의 스와이프 백 제스처를 허용할지 여부.
    ///
    /// 하위 화면(위저드)이 SwiftUI `NavigationStack`에 push되어 있는 동안 `false`로 넘기면,
    /// 바깥 스택의 깊이와 무관하게 제스처가 시작되지 않는다. 기본값 `true`는 이 파라미터를
    /// 모르는 기존 호출부(`NavigationControllerFinder { _ in }`)가 그대로 컴파일되게 하기 위함이다.
    var canPop: Bool = true
    var onFound: (UINavigationController) -> Void

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        context.coordinator.canPop = canPop
        DispatchQueue.main.async {
            if let nav = vc.navigationController {
                onFound(nav)
                context.coordinator.takeOver(nav)
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.canPop = canPop
    }

    /// 화면이 사라질 때 제스처 delegate를 원래대로 돌려놓는다.
    ///
    /// 이 브릿지가 붙는 `UINavigationController`는 탭 전체가 공유하는 스택이다.
    /// 복원하지 않으면 Coordinator 해제와 함께 delegate가 `nil`이 되고,
    /// `nil`은 "항상 시작 허용"으로 동작해 루트에서도 스와이프 백이 시도되면서 네비게이션이 멈춘다.
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        coordinator.restore()
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        weak var navigationController: UINavigationController?
        /// 우리가 가로채기 전의 delegate(`_UINavigationInteractiveTransition`). nav가 소유하므로 weak로 충분하다.
        private weak var originalDelegate: UIGestureRecognizerDelegate?
        var canPop = true

        func takeOver(_ nav: UINavigationController) {
            navigationController = nav

            guard let gesture = nav.interactivePopGestureRecognizer else { return }
            gesture.isEnabled = true
            originalDelegate = gesture.delegate
            gesture.delegate = self
        }

        func restore() {
            guard let gesture = navigationController?.interactivePopGestureRecognizer,
                  gesture.delegate === self else { return }
            gesture.delegate = originalDelegate
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return canPop && (navigationController?.viewControllers.count ?? 0) > 1
        }
    }
}


// MARK: - 위저드 스와이프 백 복원

extension View {

    /// `.toolbar(.hidden, for: .navigationBar)`을 쓰는 위저드 화면에서, 자신이 속한
    /// `NavigationStack`의 스와이프 백을 되살린다.
    ///
    /// 반드시 위저드 화면 **안**에 붙여야 한다 — 루트 폼처럼 `NavigationStack` 바깥에 붙이면
    /// 바깥 UIKit 네비게이션을 잡아 정반대로 동작한다.
    func swipeBackEnabled() -> some View {
        background(
            NavigationControllerFinder { _ in }
                .frame(width: 0, height: 0)
        )
    }
}
