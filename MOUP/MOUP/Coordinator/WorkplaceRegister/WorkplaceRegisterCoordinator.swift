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

    private let isOwnerInjected: Bool

    private lazy var inputNameViewModel = InputNameViewModel()
    private lazy var selectCategoryViewModel = SelectCategoryViewModel()
    private lazy var selectPayTypeViewModel = SelectPayTypeViewModel()
    private lazy var selectPayCalculationViewModel = SelectPayCalculationViewModel()
    private lazy var selectColorLabelViewModel = SelectColorLabelViewModel()
    private lazy var payDayPickerViewModel = PayDayPickerViewModel()
    private lazy var inputSalaryTypeViewModel =
        InputSalaryTypeViewModel(confirmedPayCalculation: selectPayCalculationViewModel.confirmedPayCalculation)

    private lazy var workplaceContainerviewModel =
        WorkplaceContainerViewModel(inputNameViewModel: inputNameViewModel,
                                    selectCategoryViewModel: selectCategoryViewModel)

    private lazy var payContainerViewModel =
        PayContainerViewModel(selectPayTypeViewModel: selectPayTypeViewModel,
                              selectPayCalculationViewModel: selectPayCalculationViewModel,
                              inputSalaryTypeViewModel: inputSalaryTypeViewModel,
                              payDayPickerViewModel: payDayPickerViewModel)

    private let workingConditionsContainerViewModel = WorkingConditionsContainerViewModel()
    private lazy var colorLabelContainerViewModel =
        ColorLabelContainerViewModel(selectColorLabelViewModel: selectColorLabelViewModel)


    // MARK: - Init
    init(navigationController: UINavigationController, isOwner: Bool) {
        self.navigationController = navigationController
        self.isOwnerInjected = isOwner
    }


    // MARK: - Start
    func start() {

        // 공통 useCase 생성
        let useCase = WorkplaceUseCase(
            workplaceRepository: WorkplaceRepository(
                workplaceService: WorkplaceService()
            )
        )

        let workerVM = WorkplaceRegisterViewModel(
            workplaceVM: workplaceContainerviewModel,
            payVM: payContainerViewModel,
            workingConditionsVM: workingConditionsContainerViewModel,
            colorLabelVM: colorLabelContainerViewModel,
            workplaceUseCase: useCase
        )

        let ownerVM = OwnerWorkplaceRegisterViewModel(
            workplaceVM: workplaceContainerviewModel,
            colorLabelVM: colorLabelContainerViewModel,
            workplaceUseCase: useCase
        )

        let vc: UIViewController

        if isOwnerInjected {
            vc = OwnerWorkplaceRegisterViewController(
                viewModel: ownerVM,
                coordinator: self
            )
        } else {
            vc = WorkplaceRegisterViewController(
                viewModel: workerVM,
                coordinator: self
            )
        }

        vc.hidesBottomBarWhenPushed = true
        navigationController.navigationBar.isHidden = false
        navigationController.pushViewController(vc, animated: false)
    }


    // MARK: - Navigation
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
        let vc = SelectColorLabelViewController(viewModel: selectColorLabelViewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func showSelectPayDayPicker() {
        let vc = PayDayPickerViewController(viewModel: payDayPickerViewModel)
        navigationController.present(vc, animated: true, completion: nil)
    }

}
