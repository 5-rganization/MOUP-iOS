//
//  LoginCoordinator.swift
//  MOUP
//
//  Created by 송규섭 on 7/26/25.
//

import UIKit

final class SignInCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let window: UIWindow

    private let signInViewModel: SignInViewModel

    init(window: UIWindow, authUseCase: AuthUseCaseProtocol) {
        self.window = window
        self.signInViewModel = SignInViewModel(authUseCase: authUseCase)
    }

    func start() {
        let signInViewController = SignInViewController(signInViewModel: signInViewModel)
        signInViewController.coordinator = self

        let nav = UINavigationController(rootViewController: signInViewController)

        window.rootViewController = signInViewController
        window.makeKeyAndVisible()
    }

    func moveToRegistration() {}
    func moveToTabBar() {}
}
