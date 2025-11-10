//
//  WorkRegisterCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 8/8/25.
//

import UIKit

final class WorkRegisterCoordinator: WorkRegisterCoordinatorProtocol {
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    private let navigationController: UINavigationController

    // MARK: - Sub ViewModels
    private lazy var selectedWorkplaceViewModel = SelectedWorkplaceViewModel(
        useCase: WorkplaceUseCase(
            workplaceRepository: WorkplaceRepository(
                workplaceService: WorkplaceService()
            )
        )
    )
    private lazy var workDatePickerViewModel = WorkDatePickerViewModel()
    private lazy var clockInViewModel = WorkTimePickerViewModel()
    private lazy var clockOutViewModel = WorkTimePickerViewModel()
    private lazy var breakPickerViewModel = WorkBreakPickerViewModel()
    private lazy var selectColorLabelViewModel = SelectColorLabelViewModel()

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Start
    func start() {
        
        let viewModel = WorkRegisterViewModel(
            selectedWorkplaceVM: selectedWorkplaceViewModel,
            datePickerVM: workDatePickerViewModel,
            clockInVM: clockInViewModel,
            clockOutVM: clockOutViewModel,
            breakPickerVM: breakPickerViewModel,
            workUseCase: WorkUseCase(workRepository: WorkRepository(workService: WorkService()))
        )

        let vc = WorkRegisterViewController(
            viewModel: viewModel,
            coordinator: self
        )

        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: false)
    }

    // MARK: - Navigation
    func showSelectWorkplace() {
        let vc = SelectedWorkplaceViewController(viewModel: selectedWorkplaceViewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func showSelectColorLabel() {
        let vc = SelectColorLabelViewController(viewModel: selectColorLabelViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
