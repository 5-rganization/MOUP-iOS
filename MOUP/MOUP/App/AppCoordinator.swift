//
//  AppCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

import UIKit
import OSLog

final class AppCoordinator: Coordinator {
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
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
        
        FCMTokenManager.shared.configure(authUseCase: authUseCase)
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogoutSuccess),
            name: .logoutSuccess,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeleteAccountSuccess),
            name: .deleteAccountSuccess,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePushNotificationTapped),
            name: .pushNotificationTapped,
            object: nil
        )
    }
    
    @objc private func handleUnauthorizedAccess() {
        tokenUseCase.deleteTokens()
        UserDefaultsManager.shared.removeUserRole()
        
        showSignIn()
    }
    
    @objc private func handleLogoutSuccess() {
        self.logger.info("로그아웃 성공, 로그인 화면으로 이동")
        showSignIn()
    }
    
    @objc private func handleDeleteAccountSuccess() {
        self.logger.info("회원 탈퇴 성공, 로그인 화면으로 이동")
        showSignIn()
    }
    
    @objc private func handlePushNotificationTapped(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let destinationString = userInfo["destination"] as? String,
              let destination = PushNotificationDestination(from: destinationString) else {
            self.logger.warning("알림 정보가 없습니다.")
            return
        }
        
        self.logger.info("푸시 알림 탭 - 목적지: \(destination.rawValue, privacy: .public)")
        
        guard tokenUseCase.checkSignedIn() else {
            self.logger.debug("로그인되지 않은 상태")
            return
        }
        
        switch destination {
        case .notificationList:
            let type = userInfo[PushNotificationKey.type] as? String
            let workerId = userInfo[PushNotificationKey.workerId] as? Int
            let workplaceId = userInfo[PushNotificationKey.workplaceId] as? Int

            moveToNotificationList(
                pushType: type,
                pushWorkerId: workerId,
                pushWorkplaceId: workplaceId
            )
        case .routineDetail:
            break
        case .workDetail:
            break
        case .home:
            break
        }
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
    
    private func moveToNotificationList(
        pushType: String? = nil,
        pushWorkerId: Int? = nil,
        pushWorkplaceId: Int? = nil,
        pushNotificationId: Int? = nil
    ) {
        guard let tabBarCoordinator = childCoordinators.first(where: { $0 is TabBarCoordinator }) as? TabBarCoordinator else {
            self.logger.error("TabBarCoordinator를 찾을 수 없습니다.")
            return
        }

        tabBarCoordinator.moveToNotificationList(
            pushType: pushType,
            pushWorkerId: pushWorkerId,
            pushWorkplaceId: pushWorkplaceId,
            pushNotificationId: pushNotificationId
        )
        self.logger.debug("알림 리스트로 이동 완료")
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

