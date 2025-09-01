//
//  SignUpCoordinator.swift
//  MOUP
//
//  Created by 송규섭 on 8/31/25.
//

import UIKit

final class SignUpCoordinator: Coordinator {
    weak var signInCoordinator: SignInCoordinator?
    let window: UIWindow
    var childCoordinators = [Coordinator]()

    private let signUpViewModel: SignUpViewModel

    init(coordinator: SignInCoordinator, signUpViewModel: SignUpViewModel, window: UIWindow) {
        self.signInCoordinator = coordinator
        self.signUpViewModel = signUpViewModel
        self.window = window
    }

    func start() {
        let userRoleViewController = UserRoleViewController()
        window.rootViewController = UINavigationController(rootViewController: userRoleViewController)
        window.makeKeyAndVisible()
    }

    func didFinishSignUp() {
        signInCoordinator?.moveToTabBar()
    }
}
