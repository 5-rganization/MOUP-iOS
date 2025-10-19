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
    private let workplaceService: WorkplaceServiceProtocol
    private let workplaceRepository: WorkplaceRepositoryProtocol
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.workplaceService = WorkplaceService()
        self.workplaceRepository = WorkplaceRepository(workplaceService: workplaceService)
        self.workplaceUseCase = WorkplaceUseCase(workplaceRepository: workplaceRepository)
    }
    
    func start() {
        let viewModel = InviteCodeInputViewModel(workplaceUseCase: workplaceUseCase)
        let vc = InviteCodeInputViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
