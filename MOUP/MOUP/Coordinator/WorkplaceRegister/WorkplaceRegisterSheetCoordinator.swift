//
//  WorkplaceRegisterSheetCoordinator.swift
//  MOUP
//
//  Created by 송규섭 on 10/17/25.
//

import UIKit

final class WorkplaceRegisterSheetCoordinator: Coordinator {
    weak var coordinator: HomeCoordinator?
    var childCoordinators = [Coordinator]()
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let navigationController: UINavigationController
    private var sheetNav: UINavigationController?
    
    init(
        navigationController: UINavigationController,
        workplaceUseCase: WorkplaceUseCaseProtocol
    ) {
        self.navigationController = navigationController
        self.workplaceUseCase = workplaceUseCase
    }
    
    func start() {
        let vc = WorkplaceRegisterSheetViewController()
        vc.coordinator = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.custom {_ in return 227 }]
            sheet.prefersGrabberVisible = true
        }
        sheetNav = nav
        navigationController.present(nav, animated: true)
    }
    
    func moveToInviteCodeInput() { // 초대 코드 등록
        guard let coordinator else { return }
        
        let inviteCodeInputCoordinator = InviteCodeInputCoordinator(
            navigationController: navigationController,
            workplaceUseCase: workplaceUseCase,
            homeCoordinator: coordinator
        )
        inviteCodeInputCoordinator.coordinator = self
        childCoordinators.append(inviteCodeInputCoordinator)
        inviteCodeInputCoordinator.start()
    }

    /// 직접 등록. 역할 판정과 화면 조립은 `HomeCoordinator`에 한 벌만 두고 위임한다.
    ///
    /// 예전엔 여기서 같은 로직을 복제하면서 비교 문자열이 `"OWNER"`로 어긋나 있었다 —
    /// 저장되는 값은 `UserRole.rawValue`, 즉 `"ROLE_OWNER"`다.
    /// 이 시트는 알바생만 거치므로 결과는 우연히 같았지만, 사장님이 이 경로를 타는 순간 깨진다.
    func moveToDirectRegistration() {
        coordinator?.moveToDirectRegistration()
    }

    func sheetDismissed() {
        coordinator?.removeChildCoordinator(self)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
