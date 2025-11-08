//
//  MyPageCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

import UIKit

final class MyPageCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController
    
    private let userService: UserServiceProtocol
    private let userRepository: UserRepositoryProtocol
    private let userUseCase: UserUseCaseProtocol
    
    private let authService: AuthServiceProtocol
    private let authRepository: AuthRepositoryProtocol
    private let authUseCase: AuthUseCaseProtocol
    
    private let noticeService: NoticeServiceProtocol
    private let noticeRepository: NoticeRepositoryProtocol
    private let noticeUseCase: NoticeUseCaseProtocol
    
    private lazy var myPageVC: MyPageViewController = {
        let viewModel = MyPageViewModel(
            userUseCase: userUseCase,
            authUseCase: authUseCase
        )
        let vc = MyPageViewController(viewModel: viewModel)
        return vc
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        self.userService = UserService()
        self.userRepository = UserRepository(userService: userService)
        self.userUseCase = UserUseCase(userRepository: userRepository)
        
        self.authService = AuthService()
        self.authRepository = AuthRepository(authService: authService)
        self.authUseCase = AuthUseCase(authRepository: authRepository)
        
        self.noticeService = NoticeService()
        self.noticeRepository = NoticeRepository(noticeService: noticeService)
        self.noticeUseCase = NoticeUseCase(noticeRepository: noticeRepository)
    }

    func start() {
        myPageVC.coordinator = self
        navigationController.pushViewController(myPageVC, animated: false)
    }
    
    func showEditNicknameModal() {
        let viewModel = EditModalViewModel(userUseCase: userUseCase)
        let editModalVC = EditModalViewController(viewModel: viewModel)
        editModalVC.modalPresentationStyle = .overFullScreen
        editModalVC.modalTransitionStyle = .crossDissolve
        editModalVC.onNicknameSaved = { [weak self] nickname in
            guard let self else { return }
            self.myPageVC.updateNickname(nickname)
        }
        navigationController.present(editModalVC, animated: false)
    }
    
    func showAccountViewController() {
        let accountVC = AccountViewController()
        accountVC.coordinator = self
        navigationController.pushViewController(accountVC, animated: true)
    }
    
    func showDeleteAccountModal() {
        let viewModel = DeleteAccountViewModel(userUseCase: userUseCase)
        let deleteAccountModalVC = DeleteAccountModalViewController(viewModel: viewModel)
        deleteAccountModalVC.modalPresentationStyle = .overFullScreen
        navigationController.present(deleteAccountModalVC, animated: false)
    }
    
    func showNoticeList() {
        let viewModel = NoticeListViewModel(noticeUseCase: noticeUseCase)
        let noticeListVC = NoticeListViewController(viewModel: viewModel)
        noticeListVC.coordinator = self
        navigationController.pushViewController(noticeListVC, animated: true)
    }
    
    func showNoticeDetail(_ notice: Notice) {
        let noticeDetailVC = NoticeDetailViewController(notice: notice)
        noticeDetailVC.coordinator = self
        navigationController.pushViewController(noticeDetailVC, animated: true)
    }
    
    func showInfoViewController() {
        let infoVC = InfoViewController()
        infoVC.coordinator = self
        navigationController.pushViewController(infoVC, animated: true)
    }
    
    func showPolicy(_ kind: PolicyKind) {
        let policyVC = PolicyViewController(
            fileName: kind.fileName,
            title: kind.title
        )
        policyVC.coordinator = self
        navigationController.pushViewController(policyVC, animated: true)
    }
    
    func showOpenSourceLicense() {
        let openSourceLicenseVC = OpenSourceViewController()
        openSourceLicenseVC.coordinator = self
        navigationController.pushViewController(openSourceLicenseVC, animated: true)
    }
    
    func showLogoutConfirm(
        from vc: UIViewController,
        onConfirm: @escaping () -> Void
    ) {
        let logoutConfirmVC = DeleteAlertViewController(
            alertTitle: "로그아웃 하시겠어요?",
            alertMessage: "다시 로그인해야 서비스를 이용할 수 있어요.",
            deleteButtonTitle: "로그아웃"
        )
        logoutConfirmVC.onDeleteConfirmed = onConfirm
        vc.present(logoutConfirmVC, animated: true)
    }
    
    func showLogoutFail(
        from vc: UIViewController,
        onConfirm: @escaping () -> Void
    ) {
        let logoutFailVC = DeleteAlertViewController(
            alertTitle: "로그아웃에 실패했어요.",
            alertMessage: "잠시 후에 다시 시도해주세요.",
            deleteButtonTitle: "확인"
        )
        logoutFailVC.onDeleteConfirmed = onConfirm
        vc.present(logoutFailVC, animated: true)
    }
}
