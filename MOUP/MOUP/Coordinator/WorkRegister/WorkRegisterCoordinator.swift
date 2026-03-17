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
    
    private let registerMode: OLDWorkRegisterMode
    private let navigationController: UINavigationController
    private var workRegisterViewModel: OLDWorkRegisterViewModel?
    
    private let isOwnerInjected: Bool
    
    private let selectedDate: Date?

    // MARK: - Sub ViewModels
    private lazy var selectedWorkplaceViewModel = OLDSelectedWorkplaceViewModel(
        useCase: WorkplaceUseCase(
            workplaceRepository: WorkplaceRepository(
                workplaceService: WorkplaceService()
            )
        )
    )
    
    private lazy var attendanceUseCase = AttendanceUseCase(
        attendanceRepository: AttendanceRepository(
            attendanceService: AttendanceService()
        )
    )
    
    private lazy var workDatePickerViewModel = OLDWorkDatePickerViewModel(initialDate: selectedDate ?? .now)
    private lazy var clockInViewModel = OLDWorkTimePickerViewModel()
    private lazy var clockOutViewModel = OLDWorkTimePickerViewModel()
    private lazy var breakPickerViewModel = OLDWorkBreakPickerViewModel()
    private lazy var selectColorLabelViewModel = SelectColorLabelViewModel()
    private lazy var repeatSettingViewModel = OLDRepeatSettingViewModel()

    // MARK: - Init
    init(navigationController: UINavigationController, isOwnerInjected: Bool, selectedDate: Date?, mode: OLDWorkRegisterMode) {
        self.navigationController = navigationController
        self.isOwnerInjected = isOwnerInjected
        self.selectedDate = selectedDate
        self.registerMode = mode
    }

    // MARK: - Start
    func start() {
        
        let userRole: UserRole = isOwnerInjected ? .owner : .worker
        
        let viewModel = OLDWorkRegisterViewModel(
            mode: registerMode,
            selectedWorkplaceVM: selectedWorkplaceViewModel,
            datePickerVM: workDatePickerViewModel,
            clockInVM: clockInViewModel,
            clockOutVM: clockOutViewModel,
            breakPickerVM: breakPickerViewModel,
            repeatSettingVM: repeatSettingViewModel,
            workUseCase: WorkUseCase(workRepository: WorkRepository(workService: WorkService())),
            selectedDate: selectedDate,
            userRole: userRole
            )
            
        let vc: UIViewController
        if isOwnerInjected {
            vc = OLDOwnerWorkRegisterViewController(viewModel: viewModel, coordinator: self)
        } else {
            vc = OLDWorkRegisterViewController(viewModel: viewModel, coordinator: self)
        }
        self.workRegisterViewModel = viewModel

        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Navigation
    func showSelectWorkplace() {
        let vc = OLDSelectedWorkplaceViewController(viewModel: selectedWorkplaceViewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func showSelectColorLabel() {
        let vc = SelectColorLabelViewController(viewModel: selectColorLabelViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showRepeatSetting() {
        let vc = OLDRepeatSettingViewController(viewModel: repeatSettingViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showWorkerSelection(workplaceId: Int, completion: @escaping ([Int]) -> Void) {
        Task {
            do {
                let workers = try await attendanceUseCase.fetchWorkplaceWorkers(
                    workplaceId: workplaceId,
                    isActiveOnly: true
                )

                let mapped = workers.map { worker in
                    (id: worker.id, name: worker.nickname)
                }

                let vc = OLDSelectedWorkerViewController(workers: mapped)

                vc.onWorkersSelected = { selectedIds in
                    print("선택된 알바 ID:", selectedIds)
                    completion(selectedIds)
                }

                navigationController.pushViewController(vc, animated: true)

            } catch {
                print("근무자 불러오기 실패:", error)
            }
        }
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
