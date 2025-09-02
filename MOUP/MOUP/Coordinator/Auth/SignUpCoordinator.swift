//
//  SignUpCoordinator.swift
//  MOUP
//
//  Created by 송규섭 on 8/31/25.
//

import UIKit

final class SignUpCoordinator: Coordinator {
    weak var signInCoordinator: SignInCoordinator?
    private var navigationController: UINavigationController?
    let window: UIWindow
    var childCoordinators = [Coordinator]()

    private let signUpViewModel: SignUpViewModel

    init(coordinator: SignInCoordinator, signUpViewModel: SignUpViewModel, window: UIWindow) {
        self.signInCoordinator = coordinator
        self.signUpViewModel = signUpViewModel
        self.window = window
    }

    func start() {
        let nicknameViewModel = NicknameViewModel()
        let nicknameViewController = NicknameViewController(nicknameViewModel: nicknameViewModel)
        nicknameViewController.coordinator = self
        let nav = UINavigationController(rootViewController: nicknameViewController)
        self.navigationController = nav
        DispatchQueue.main.async {
            UIView.transition(with: self.window, duration: 0.3, options: [.transitionCrossDissolve]) {
                // TODO: - window.rootViewController를 갈아끼우는 과정에서 깜빡거리는 현상 해결 필요
                self.window.rootViewController = nav
            }
            self.window.makeKeyAndVisible()
        }
    }

    /// 닉네임 설정 페이지로 이동
    func goToSetUserRole(with nickname: String) {
        let userRoleViewModel = UserRoleViewModel(nickname: nickname)
        let userRoleViewController = UserRoleViewController(userRoleViewModel: userRoleViewModel)
        userRoleViewController.coordinator = self
        navigationController?.pushViewController(userRoleViewController, animated: true)
    }

    func didFinishSignUp() {
        print("didFinishSignUp")
        signInCoordinator?.moveToTabBar()
    }
}
