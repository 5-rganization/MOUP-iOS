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
    private let googleAuthService: GoogleAuthServiceProtocol
    private let googleAuthRepository: GoogleAuthRepositoryProtocol
    private let googleAuthUseCase: GoogleAuthUseCaseProtocol

    init(window: UIWindow) {
        self.window = window
        self.googleAuthService = GoogleAuthService()
        self.googleAuthRepository = GoogleAuthRepository(googleAuthService: googleAuthService)
        self.googleAuthUseCase = GoogleAuthUseCase(googleAuthRepository: googleAuthRepository)
        self.signInViewModel = SignInViewModel(googleAuthUseCase: googleAuthUseCase)
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
