//
//  WorkplaceRegisterCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/24/25.
//

import UIKit

final class WorkplaceRegisterCoordinator: WorkplaceRegisterCoordinatorProtocol {
    var childCoordinators = [Coordinator]()
    private let navigationController: UINavigationController
    
    func start() {
        let workplaceContainerviewModel = WorkplaceContainerViewModel()
        let workingConditionsContainerViewModel = WorkingConditionsContainerViewModel()
        let vc = WorkplaceRegisterViewController(
            workplaceViewModel: workplaceContainerviewModel,
            workingConditionsContainerViewModel: workingConditionsContainerViewModel,
            coordinator: self
        )
        navigationController.pushViewController(vc, animated: false)
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showSelectCategory() {
        let vc = SelectCategoryViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
