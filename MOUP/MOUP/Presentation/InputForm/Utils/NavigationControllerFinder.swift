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
/// **사용 예시**
/// ```swift
/// struct SomeView: View {
///     @State private var navigationController: UINavigationController?
///
///     var body: some View {
///         NavigationStack {
///             content
///                 .toolbar(.hidden, for: .navigationBar)
///         }
///         .background(
///             NavigationControllerFinder { nav in
///                 navigationController = nav
///             }
///                 .frame(width: 0, height: 0)
///         )
///     }
/// }
/// ```
struct NavigationControllerFinder: UIViewControllerRepresentable {
    var onFound: (UINavigationController) -> Void
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        DispatchQueue.main.async {
            if let nav = vc.navigationController {
                onFound(nav)
                context.coordinator.takeOver(nav)
            }
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

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
            return (navigationController?.viewControllers.count ?? 0) > 1
        }
    }
}
