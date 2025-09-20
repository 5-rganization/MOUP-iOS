//
//  SignUpCoordinator.swift
//  MOUP
//
//  Created by 송규섭 on 8/31/25.
//

import UIKit
import RxSwift

final class SignUpCoordinator: Coordinator {
    weak var signInCoordinator: SignInCoordinator?
    private var navigationController: UINavigationController?
    let window: UIWindow
    var childCoordinators = [Coordinator]()
    private let provider: LoginProvider // 회원가입 플랫폼 식별용
    private let authorizationCode: String
    private let authUseCase: AuthUseCaseProtocol
    private let disposeBag = DisposeBag()

    private var userRoleViewModel: UserRoleViewModel?

    init(
        coordinator: SignInCoordinator,
        window: UIWindow,
        provider: LoginProvider,
        authorizationCode: String,
        authUseCase: AuthUseCaseProtocol
    ) {
        self.signInCoordinator = coordinator
        self.window = window
        self.provider = provider
        self.authorizationCode = authorizationCode
        self.authUseCase = authUseCase
    }

    func start() {
        let nicknameViewModel = NicknameViewModel(provider: provider)
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
    func goToSetUserRole(with nickname: String, provider: LoginProvider) {
        print("goToSetUserRole - nickname: \(nickname)")
        self.userRoleViewModel = UserRoleViewModel(
            nickname: nickname,
            authorizationCode: authorizationCode,
            provider: provider,
            authUseCase: authUseCase
        )
        let userRoleViewController = UserRoleViewController(userRoleViewModel: userRoleViewModel!)
        userRoleViewController.coordinator = self
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(userRoleViewController, animated: true)
        }
    }

    func didSetUserRole(userRole: UserRole) {
        let roleConfirmVC = RoleConfirmationViewController(userRole: userRole)
        roleConfirmVC.modalPresentationStyle = .overFullScreen
        roleConfirmVC.modalTransitionStyle = .crossDissolve
        roleConfirmVC.confirmButtonTapRelay
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.userRoleViewModel?.signUpTriggerRelay.accept(())
            })
            .disposed(by: disposeBag)
        DispatchQueue.main.async {
            self.navigationController?.present(roleConfirmVC, animated: true)
        }
    }

    func didFinishSignUp() {
        print("didFinishSignUp")
        signInCoordinator?.moveToTabBar()
    }
}
