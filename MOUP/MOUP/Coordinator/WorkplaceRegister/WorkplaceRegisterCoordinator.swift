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
    private lazy var selectPayTypeViewModel = SelectPayTypeViewModel()
    private lazy var selectPayCalculationViewModel = SelectPayCalculationViewModel()
    private lazy var inputSalaryTypeViewModel = InputSalaryTypeViewModel(confirmedPayCalculation: selectPayCalculationViewModel.confirmedPayCalculation)
    private lazy var workplaceContainerviewModel = WorkplaceContainerViewModel(inputNameViewModel: inputNameViewModel, selectCategoryViewModel: selectCategoryViewModel)
    private lazy var payContainerViewModel = PayContainerViewModel(selectPayTypeViewModel: selectPayTypeViewModel, selectPayCalculationViewModel: selectPayCalculationViewModel, inputSalaryTypeViewModel: inputSalaryTypeViewModel)
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
        let vc = SelectPayTypeViewController(viewModel: selectPayTypeViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSelectPayCalculation() {
        let vc = SelectPayCalculationViewController(viewModel: selectPayCalculationViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showInputSalaryType() {
        let vc = InputSalaryTypeViewController(viewModel: inputSalaryTypeViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSelectColorLabel() {
        let vc = SelectColorLabelViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
