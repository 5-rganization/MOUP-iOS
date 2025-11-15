//
//  InviteCodeInputCoordinator.swift
//  MOUP
//
//  Created by 송규섭 on 10/18/25.
//

import UIKit

final class InviteCodeInputCoordinator: Coordinator {
    weak var coordinator: WorkplaceRegisterSheetCoordinator?
    var childCoordinators = [Coordinator]()
    private let navigationController: UINavigationController
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    
    init(
        navigationController: UINavigationController,
        workplaceUseCase: WorkplaceUseCaseProtocol
    ) {
        self.navigationController = navigationController
        self.workplaceUseCase = workplaceUseCase
    }
    
    func start() {
        let viewModel = InviteCodeInputViewModel(workplaceUseCase: workplaceUseCase)
        let vc = InviteCodeInputViewController(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToInviteCodeResult(workplace: InviteCodeWorkplace) {
        DispatchQueue.main.async {
            let viewModel = InviteCodeResultViewModel(workplace: workplace)
            let vc = InviteCodeResultViewController(viewModel: viewModel)
            self.navigationController.pushViewController(vc, animated: true)
        }
    }
}
