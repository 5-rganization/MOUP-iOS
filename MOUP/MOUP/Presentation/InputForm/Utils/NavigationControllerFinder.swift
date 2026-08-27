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
/// 이 브릿지는 호스팅 컨트롤러의 부모, 즉 탭이 공유하는 **바깥 UIKit 네비게이션**을 찾는다.
/// SwiftUI 쪽 `NavigationStack`이 그 위에 하위 화면(위저드)을 push한 상태에서도 바깥 스택의
/// `viewControllers.count`는 바뀌지 않으므로, 하위 화면이 떠 있는 동안은 `canPop`으로
/// 제스처 자체를 막아야 스와이프 백이 하위 화면을 건너뛰고 상위 화면까지 나가버리는 것을 막을 수 있다.
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
