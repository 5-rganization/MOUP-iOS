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

    private let signInViewModel: SignInViewModel

    init(coordinator: AppCoordinator, window: UIWindow, authUseCase: AuthUseCaseProtocol) {
        self.appCoordinator = coordinator
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

    func moveToSignUp() {
        let signUpViewModel = SignUpViewModel()
        let signUpCoordinator = SignUpCoordinator(coordinator: self, signUpViewModel: signUpViewModel, window: window)
        signUpCoordinator.start()
        childCoordinators.append(signUpCoordinator) // moveToTabBar 등 공개 메서드 유지를 위함
    }

    func moveToTabBar() {
        print("moveToTabBar")
        appCoordinator?.moveToTabBar()
    }
}
