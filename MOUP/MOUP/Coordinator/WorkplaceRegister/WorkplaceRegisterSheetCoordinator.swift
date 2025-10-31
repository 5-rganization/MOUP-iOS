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
        let inviteCodeInputCoordinator = InviteCodeInputCoordinator(
            navigationController: navigationController,
            workplaceUseCase: workplaceUseCase
        )
        inviteCodeInputCoordinator.coordinator = self
        childCoordinators.append(inviteCodeInputCoordinator)
        inviteCodeInputCoordinator.start()
    }

    func moveToDirectRegistration() {
        print("moveToDirectRegistration")

        sheetNav?.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            let coordinator = WorkplaceRegisterCoordinator(navigationController: self.navigationController)
            self.childCoordinators.append(coordinator)
            coordinator.start()
        }
    }

    
    func sheetDismissed() {
        coordinator?.removeChildCoordinator(self)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
