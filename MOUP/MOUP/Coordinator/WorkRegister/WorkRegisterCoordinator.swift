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
    private var workRegisterViewModel: WorkRegisterViewModel?
    
    private let isOwnerInjected: Bool

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
    private lazy var repeatSettingViewModel = RepeatSettingViewModel()

    // MARK: - Init
    init(navigationController: UINavigationController, isOwnerInjected: Bool) {
        self.navigationController = navigationController
        self.isOwnerInjected = isOwnerInjected
    }

    // MARK: - Start
    func start() {
        let viewModel = WorkRegisterViewModel(
            selectedWorkplaceVM: selectedWorkplaceViewModel,
            datePickerVM: workDatePickerViewModel,
            clockInVM: clockInViewModel,
            clockOutVM: clockOutViewModel,
            breakPickerVM: breakPickerViewModel,
            repeatSettingVM: repeatSettingViewModel,
            workUseCase: WorkUseCase(workRepository: WorkRepository(workService: WorkService()))
            )
            
        let vc: UIViewController
        if isOwnerInjected {
            vc = OwnerWorkRegisterViewController(viewModel: viewModel, coordinator: self)
        } else {
            vc = WorkRegisterViewController(viewModel: viewModel, coordinator: self)
        }
        self.workRegisterViewModel = viewModel

        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
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
    
    func showRepeatSetting() {
        let vc = RepeatSettingViewController(viewModel: repeatSettingViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showRoutineSelection() {
        let coordinator = RoutineSelectionCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        coordinator.onRoutinesSelected = { [weak self] routines in
            guard let self else { return }
            
            self.workRegisterViewModel?.selectedRoutines.accept(routines)
        }
        
        coordinator.start()
    }
}
