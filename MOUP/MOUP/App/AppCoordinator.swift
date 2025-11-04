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
        self.tokenService = TokenService()
        self.tokenRepository = TokenRepository(tokenService: tokenService)
        self.tokenUseCase = TokenUseCase(tokenRepository: tokenRepository)
        self.authService = AuthService()
        self.authRepository = AuthRepository(authService: authService)
        self.authUseCase = AuthUseCase(authRepository: authRepository)
        print("AccessToken: \(KeychainManager.shared.read(key: "accessToken"))")
        setupNetworkManager()
        setupNotifications()
    }

    func start() {
        if tokenUseCase.checkSignedIn() {
            if let rawValue = UserDefaultsManager.shared.userRole,
               let role = UserRole(rawValue: rawValue) {
                showTabBar(userRole: role)
            } else {
                handleUnauthorizedAccess()
            }
        } else {
            showSignIn()
        }
    }
    
    private func setupNetworkManager() {
        NetworkManager.configure(tokenUseCase: tokenUseCase)
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
        UserDefaultsManager.shared.removeUserRole()
        
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
    
    private func showTabBar(userRole: UserRole) {
        childCoordinators.removeAll()
        
        let tabBarCoordinator = TabBarCoordinator(
            coordinator: self,
            window: window,
            authUseCase: authUseCase,
            userRole: userRole
        )
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
    }
    
    // MARK: - Public Methods
    
    func moveToTabBar() {
        if let rawValue = UserDefaultsManager.shared.userRole,
           let role = UserRole(rawValue: rawValue) {
            showTabBar(userRole: role)
        } else {
            handleUnauthorizedAccess()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

