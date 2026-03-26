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
                context.coordinator.navigationController = nav
                nav.interactivePopGestureRecognizer?.isEnabled = true
                nav.interactivePopGestureRecognizer?.delegate = context.coordinator
            }
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        weak var navigationController: UINavigationController?
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return (navigationController?.viewControllers.count ?? 0) > 1
        }
    }
}
