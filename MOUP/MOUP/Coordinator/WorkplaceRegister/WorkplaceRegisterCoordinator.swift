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
    private lazy var inputNameViewModel = InputNameViewModel()
    private lazy var selectCategoryViewModel = SelectCategoryViewModel()
    private lazy var workplaceContainerviewModel = WorkplaceContainerViewModel(inputNameViewModel: inputNameViewModel, selectCategoryViewModel: selectCategoryViewModel)
    private let payContainerViewModel = PayContainerViewModel()
    private let workingConditionsContainerViewModel = WorkingConditionsContainerViewModel()
    private let colorLabelContainerViewModel = ColorLabelContainerViewModel()
    
    func start() {
        let vc = WorkplaceRegisterViewController(
            workplaceContainerViewModel: workplaceContainerviewModel,
            payContainerViewModel: payContainerViewModel,
            workingConditionsContainerViewModel: workingConditionsContainerViewModel,
            colorLabelContainerViewModel: colorLabelContainerViewModel,
            coordinator: self
        )
        navigationController.pushViewController(vc, animated: false)
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showSelectCategory() {
        let vc = SelectCategoryViewController(viewModel: selectCategoryViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showInputName() {
        let vc = InputNameViewController(viewModel: inputNameViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSelectPayType() {
        let vc = SelectPayTypeViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSelectPayCalculation() {
        let vc = SelectPayCalculationViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showInputSalaryType() {
        let vc = InputSalaryTypeViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSelectColorLabel() {
        let vc = SelectColorLabelViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
