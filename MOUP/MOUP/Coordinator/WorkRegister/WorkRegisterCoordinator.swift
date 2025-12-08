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
    
    private let registerMode: WorkRegisterMode
    private let navigationController: UINavigationController
    private var workRegisterViewModel: WorkRegisterViewModel?
    
    private let isOwnerInjected: Bool
    
    private let selectedDate: Date?

    // MARK: - Sub ViewModels
    private lazy var selectedWorkplaceViewModel = SelectedWorkplaceViewModel(
        useCase: WorkplaceUseCase(
            workplaceRepository: WorkplaceRepository(
                workplaceService: WorkplaceService()
            )
        )
    )
    private lazy var workDatePickerViewModel = WorkDatePickerViewModel(initialDate: selectedDate ?? .now)
    private lazy var clockInViewModel = WorkTimePickerViewModel()
    private lazy var clockOutViewModel = WorkTimePickerViewModel()
    private lazy var breakPickerViewModel = WorkBreakPickerViewModel()
    private lazy var selectColorLabelViewModel = SelectColorLabelViewModel()
    private lazy var repeatSettingViewModel = RepeatSettingViewModel()

    // MARK: - Init
    init(navigationController: UINavigationController, isOwnerInjected: Bool, selectedDate: Date?, mode: WorkRegisterMode) {
        self.navigationController = navigationController
        self.isOwnerInjected = isOwnerInjected
        self.selectedDate = selectedDate
        self.registerMode = mode
    }

    // MARK: - Start
    func start() {
        let viewModel = WorkRegisterViewModel(
            mode: registerMode,
            selectedWorkplaceVM: selectedWorkplaceViewModel,
            datePickerVM: workDatePickerViewModel,
            clockInVM: clockInViewModel,
            clockOutVM: clockOutViewModel,
            breakPickerVM: breakPickerViewModel,
            repeatSettingVM: repeatSettingViewModel,
            workUseCase: WorkUseCase(workRepository: WorkRepository(workService: WorkService())),
            selectedDate: selectedDate
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
    
    func showWorkerSelection() {
        
        // TODO: UI 테스트 용 추후 API 연동 
        let vc = SelectedWorkerViewController(workers: [
            (id: 1, name: "테스트 유저1"),
            (id: 2, name: "테스트 유저2"),
            (id: 3, name: "테스트 유저3"),
        ])
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
