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
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = WorkplaceRegisterSheetViewController()
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom {_ in return 227 }]
            sheet.prefersGrabberVisible = true
        }
        vc.modalPresentationStyle = .pageSheet
        navigationController.present(vc, animated: true)
    }
    
    func moveToInviteCodeInput() {
        
    }

    func moveToDirectRegistration() { // 직접 등록하기
        let coordinator = WorkplaceRegisterCoordinator(navigationController: self.navigationController)
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
