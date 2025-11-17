//
//  InviteCodeInputCoordinator.swift
//  MOUP
//
//  Created by 송규섭 on 10/18/25.
//

import UIKit
import RxSwift

final class InviteCodeInputCoordinator: Coordinator, WorkplaceRegisterCoordinatorProtocol {
    
    weak var coordinator: WorkplaceRegisterSheetCoordinator?
    var childCoordinators = [Coordinator]()
    
    private let navigationController: UINavigationController
    private let workplaceUseCase: WorkplaceUseCaseProtocol

    private lazy var selectPayTypeVM = SelectPayTypeViewModel()
    private lazy var selectPayCalcVM = SelectPayCalculationViewModel()
    private lazy var inputSalaryTypeVM = InputSalaryTypeViewModel(
        confirmedPayCalculation: selectPayCalcVM.confirmedPayCalculation
    )
    private lazy var payDayPickerVM = PayDayPickerViewModel()
    private lazy var workingConditionsVM = WorkingConditionsContainerViewModel()
    private lazy var selectColorLabelVM = SelectColorLabelViewModel()
    private lazy var colorLabelVM = ColorLabelContainerViewModel(
        selectColorLabelViewModel: selectColorLabelVM
    )
    private lazy var payVM = PayContainerViewModel(
        selectPayTypeViewModel: selectPayTypeVM,
        selectPayCalculationViewModel: selectPayCalcVM,
        inputSalaryTypeViewModel: inputSalaryTypeVM,
        payDayPickerViewModel: payDayPickerVM
    )

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
    
    func moveToInviteCodeResult(workplace: InviteCodeWorkplace, inviteCode: String) {
        let viewModel = InviteCodeResultViewModel(workplace: workplace, inviteCode: inviteCode)
        let vc = InviteCodeResultViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func moveToInviteCodeWorkplaceRegister(workplaceName: String, inviteCode: String) {

        // Main ViewModel
        let viewModel = InviteCodeWorkplaceRegisterViewModel(
            inviteCode: inviteCode,
            payVM: payVM,
            workingConditionsVM: workingConditionsVM,
            colorLabelVM: colorLabelVM,
            workplaceUseCase: workplaceUseCase
        )

        let vc = InviteCodeWorkplaceRegisterViewController(
            workplaceName: workplaceName,
            inviteCode: inviteCode,
            viewModel: viewModel,
            coordinator: self
        )
        navigationController.pushViewController(vc, animated: true)
    }
}

extension InviteCodeInputCoordinator {
    
    func showSelectCategory() {
        return
    }
    
    func showInputName() {
        return
    }

    func showSelectPayType() {
        let vc = SelectPayTypeViewController(viewModel: selectPayTypeVM)
        navigationController.pushViewController(vc, animated: true)
    }

    func showSelectPayCalculation() {
        let vc = SelectPayCalculationViewController(viewModel: selectPayCalcVM)
        navigationController.pushViewController(vc, animated: true)
    }

    func showInputSalaryType() {
        let vc = InputSalaryTypeViewController(viewModel: inputSalaryTypeVM)
        navigationController.pushViewController(vc, animated: true)
    }

    func showSelectPayDayPicker() {
        let vc = PayDayPickerViewController(viewModel: payDayPickerVM)
        navigationController.present(vc, animated: true)
    }

    func showSelectColorLabel() {
        let vc = SelectColorLabelViewController(viewModel: selectColorLabelVM)
        navigationController.pushViewController(vc, animated: true)
    }
}

