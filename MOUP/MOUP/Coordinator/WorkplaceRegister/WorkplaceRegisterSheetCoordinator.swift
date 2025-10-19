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
    private let navigationController: UINavigationController
    private var sheetNav: UINavigationController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
    
    func moveToInviteCodeInput() {
        let inviteCodeInputCoordinator = InviteCodeInputCoordinator(navigationController: navigationController)
        inviteCodeInputCoordinator.coordinator = self
        childCoordinators.append(inviteCodeInputCoordinator)
        inviteCodeInputCoordinator.start()
    }

    func moveToDirectRegistration() { // 직접 등록하기
        print("moveToDirectRegistration")
        guard let sheetNav else { return }
        let coordinator = WorkplaceRegisterCoordinator(navigationController: sheetNav)
        childCoordinators.append(coordinator)
        DispatchQueue.main.async {
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
