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

    private let authService: AuthServiceProtocol
    private let authRepository: AuthRepositoryProtocol
    private let authUseCase: AuthUseCaseProtocol
    private let tokenService: TokenServiceProtocol
    private let tokenRepository: TokenRepositoryProtocol
    private let tokenUseCase: TokenUseCaseProtocol

    init(window: UIWindow) {
        self.window = window
        self.authService = AuthService()
        self.authRepository = AuthRepository(authService: authService)
        self.authUseCase = AuthUseCase(authRepository: authRepository)
        self.tokenService = TokenService()
        self.tokenRepository = TokenRepository(tokenService: tokenService)
        self.tokenUseCase = TokenUseCase(tokenRepository: tokenRepository)
        
        setupNotifications()
    }

    func start() {
        if tokenUseCase.checkSignedIn() {
            showTabBar()
        } else {
            showSignIn()
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUnauthorizedAccess),
            name: .unauthorizedAccessDetected,
            object: nil
        )
    }
    
    @objc private func handleUnauthorizedAccess() {
        tokenUseCase.deleteTokens()
        
        showSignIn()
    }
    
    private func showSignIn() {
        childCoordinators.removeAll()
        
        let signInCoordinator = SignInCoordinator(
            coordinator: self,
            window: window,
            authUseCase: authUseCase
        )
        childCoordinators.append(signInCoordinator)
        signInCoordinator.start()
    }
    
    private func showTabBar() {
        childCoordinators.removeAll()
        
        let tabBarCoordinator = TabBarCoordinator(
            coordinator: self,
            window: window,
            authUseCase: authUseCase
        )
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
    }
    
    // MARK: - Public Methods
    
    func moveToTabBar() {
        showTabBar()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

