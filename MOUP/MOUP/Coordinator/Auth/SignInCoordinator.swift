//
//  LoginCoordinator.swift
//  MOUP
//
//  Created by 송규섭 on 7/26/25.
//

import UIKit

final class SignInCoordinator: Coordinator {
    weak var appCoordinator: AppCoordinator?
    var childCoordinators = [Coordinator]()
    let window: UIWindow

    private let authUseCase: AuthUseCaseProtocol
    private lazy var signInViewModel = SignInViewModel(authUseCase: authUseCase)

    init(coordinator: AppCoordinator, window: UIWindow, authUseCase: AuthUseCaseProtocol) {
        self.appCoordinator = coordinator
        self.window = window

        self.authUseCase = authUseCase
    }

    func start() {
        let signInViewController = SignInViewController(signInViewModel: signInViewModel)
        signInViewController.coordinator = self

        let nav = UINavigationController(rootViewController: signInViewController)

        window.rootViewController = signInViewController
        window.makeKeyAndVisible()
    }

    func moveToSignUp(provider: LoginProvider, authorizationCode: String) {
        let signUpCoordinator = SignUpCoordinator(
            coordinator: self,
            window: window,
            provider: provider,
            authorizationCode: authorizationCode,
            authUseCase: authUseCase
        )
        signUpCoordinator.start()
        childCoordinators.append(signUpCoordinator) // moveToTabBar 등 공개 메서드 유지를 위함
    }

    func moveToTabBar() {
        print("moveToTabBar")
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.appCoordinator?.moveToTabBar()
        }
    }
}
