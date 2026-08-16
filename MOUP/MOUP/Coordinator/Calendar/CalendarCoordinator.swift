//
//  CalendarCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

import OSLog
import SwiftUI
import UIKit

import RxSwift

/// `CalendarViewController` Coordinator
final class CalendarCoordinator: Coordinator {
    
    // MARK: - Properties
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    var childCoordinators = [Coordinator]()
    private lazy var calendarVM = CalendarViewModel(workUseCase: self.workUseCase, workplaceUseCase: self.workplaceUseCase)
    private lazy var calendarVC = CalendarViewController(coordinator: self, viewModel: calendarVM)
    
    // Initializer Injections
    private let navigationController: UINavigationController
    private let workService: WorkServiceProtocol
    private let workRepository: WorkRepositoryProtocol
    private let workUseCase: WorkUseCaseProtocol
    private let workplaceService: WorkplaceServiceProtocol
    private let workplaceRepository: WorkplaceRepositoryProtocol
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        self.workService = WorkService()
        self.workRepository = WorkRepository(workService: workService)
        self.workUseCase = WorkUseCase(workRepository: workRepository)
        
        self.workplaceService = WorkplaceService()
        self.workplaceRepository = WorkplaceRepository(workplaceService: workplaceService)
        self.workplaceUseCase = WorkplaceUseCase(workplaceRepository: workplaceRepository)
        
    }
    
    // MARK: - Coordinator Methods
    func start() {
        navigationController.pushViewController(calendarVC, animated: false)
    }
    
    func showYearMonthPicker(currYear: Int, currMonth: Int) {
        let yearMonthCoordinator = YearMonthPickerCoordinator(parentCoordinator: self,
                                                              navigationController: navigationController,
                                                              currYear: currYear,
                                                              currMonth: currMonth)
        yearMonthCoordinator.start()
        childCoordinators.append(yearMonthCoordinator)
    }
    
    func showFilter(calendarMode: CalendarMode, selectedFilterWorkplace: WorkplaceSummary?) {
        let filterCoordinator = FilterCoordinator(parentCoordinator: self,
                                                  navigationController: navigationController,
                                                  workplaceUseCase: workplaceUseCase,
                                                  calendarMode: calendarMode,
                                                  selectedFilterWorkplace: selectedFilterWorkplace)
        filterCoordinator.start()
        childCoordinators.append(filterCoordinator)
    }
    
    func showCalendarWorkList(selectedDate: Date, calendarWorkList: Observable<[WorkSummary]>, calendarMode: CalendarMode) {
        let calendarWorkListCoordinator = CalendarWorkListCoordinator(parentCoordinator: self,
                                                                      navigationController: navigationController,
                                                                      workUseCase: workUseCase,
                                                                      selectedDate: selectedDate,
                                                                      calendarWorkList: calendarWorkList,
                                                                      calendarMode: calendarMode)
        calendarWorkListCoordinator.start()
        childCoordinators.append(calendarWorkListCoordinator)
    }
    
    func dismissCalendarWorkList() {
        navigationController.dismiss(animated: true)
    }
    
    func calendarWorkListDismissedByUser() {
        calendarVC.deselectCell()
    }
    
    func disappeared(_ coordinator: Coordinator) {
        removeChildCoordinator(coordinator)
    }
}

// MARK: - Private Methods
private extension CalendarCoordinator {
    func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
    }
}

// MARK: - YearMonthCoordinator Methods
extension CalendarCoordinator {
    /// 연/월 이동 취소
    func cancelled(_ coordinator: YearMonthPickerCoordinator) {
        navigationController.dismiss(animated: true)
    }
    
    /// 선택한 연/월로 이동
    func changeYearMonth(_ coordinator: YearMonthPickerCoordinator, focusedYear: Int, focusedMonth: Int) {
        calendarVC.updateYearMonth(focusedYear: focusedYear, focusedMonth: focusedMonth)
        navigationController.dismiss(animated: true)
    }
}

// MARK: - FilterCoordinator Methods
extension CalendarCoordinator {
    /// 선택한 필터 적용
    func applyFilter(_ coordinator: FilterCoordinator, filterWorkplace: WorkplaceSummary?) {
        calendarVC.updateFilter(filterWorkplace: filterWorkplace)
        navigationController.dismiss(animated: true)
    }
}

// MARK: - CalendarWorkListCoordinator Methods
extension CalendarCoordinator {
    /// 알바생 근무 등록/수정 화면 표시
    ///
    /// SwiftUI로 재구현한 화면이라 `UIHostingController`로 감싸 push 한다.
    /// 저장 후 pop 하면 `CalendarViewController.viewWillAppear`가 재조회하므로 별도 갱신 통지는 필요 없다.
    func showWorkerWorkRegister(selectedDate: Date? = nil, workToEdit: WorkSummary?) {
        let mode: WorkerWorkRegisterView.Mode = workToEdit.map { .edit(workId: $0.id) }
            ?? .create(selectedDate: selectedDate ?? .now)

        let hostingVC = UIHostingController(
            rootView: WorkerWorkRegisterView(navigationController: navigationController,
                                             mode: mode,
                                             workUseCase: workUseCase,
                                             workplaceUseCase: workplaceUseCase)
        )
        hostingVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(hostingVC, animated: true)
    }
    
    func showOwnerWorkRegister(selectedDate: Date? = nil, workToEdit: WorkSummary?) {
        if let workToEdit {
            let coordinator = WorkRegisterCoordinator(navigationController: navigationController, isOwnerInjected: false, selectedDate: selectedDate, mode: .edit(workId: workToEdit.id))
            childCoordinators.append(coordinator)
            coordinator.start()
        } else {
            let coordinator = WorkRegisterCoordinator(navigationController: navigationController, isOwnerInjected: true, selectedDate: selectedDate, mode: .create)
            childCoordinators.append(coordinator)
            coordinator.start()
        }
    }
    
    /// 캘린더 업데이트 요청
    func updateDataSource() {
        calendarVC.updateDataSource()
    }
}
