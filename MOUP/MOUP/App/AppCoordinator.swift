//
//  AppCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let window: UIWindow
    var isSignedIn: Bool // TODO: - 실제 로그인 여부를 알 수 있도록 변경

    private let authService: AuthServiceProtocol
    private let authRepository: AuthRepositoryProtocol
    private let authUseCase: AuthUseCaseProtocol

    init(window: UIWindow, isSignedIn: Bool) {
        self.window = window
        self.isSignedIn = isSignedIn
        print("자동 로그인 가능 여부 : \(isSignedIn)")
        self.authService = AuthService()
        self.authRepository = AuthRepository(googleAuthService: authService)
        self.authUseCase = AuthUseCase(googleAuthRepository: authRepository)
    }

    func start() {
        if isSignedIn {
            let tabBarCoordinator = TabBarCoordinator(window: window, authUseCase: authUseCase)
            childCoordinators.append(tabBarCoordinator)
            tabBarCoordinator.start()
        } else {
            let signInCoordinator = SignInCoordinator(coordinator: self, window: window, authUseCase: authUseCase)
            childCoordinators.append(signInCoordinator)
            signInCoordinator.start()
        }
    }

    func moveToTabBar() {
        childCoordinators.removeAll()
        let tabBarCoordinator = TabBarCoordinator(window: window, authUseCase: authUseCase)
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
    }
}

