//
//  CalendarCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

import UIKit
import OSLog

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
    
    func showCalendarWorkList(selectedDay: Int, calendarWorkList: Observable<[WorkSummary]>, calendarMode: CalendarMode) {
        let calendarWorkListCoordinator = CalendarWorkListCoordinator(parentCoordinator: self,
                                                                      navigationController: navigationController,
                                                                      workUseCase: workUseCase,
                                                                      selectedDay: selectedDay,
                                                                      calendarWorkList: calendarWorkList,
                                                                      calendarMode: calendarMode)
        calendarWorkListCoordinator.start()
        childCoordinators.append(calendarWorkListCoordinator)
    }
    
    func dismissCalendarWorkList() {
        guard let coordinator = childCoordinators.first(where: { $0 is CalendarWorkListCoordinator }) else {
            fatalError("\(#function) 실행 실패 - childCoordinators에 CalendarWorkListCoordinator가 존재하지 않습니다.")
        }
        removeChildCoordinator(coordinator, needToDismiss: true)
    }
    
    func dismissed(_ coordinator: Coordinator) {
        if coordinator is CalendarWorkListCoordinator { calendarVC.deselectCell() }
        removeChildCoordinator(coordinator, needToDismiss: false)
    }
}

// MARK: - Private Methods
private extension CalendarCoordinator {
    func removeChildCoordinator(_ coordinator: Coordinator, needToDismiss: Bool) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        if needToDismiss { navigationController.dismiss(animated: true) }
    }
}

// MARK: - YearMonthCoordinator Methods
extension CalendarCoordinator {
    /// 연/월 이동 취소
    func cancelled(_ coordinator: YearMonthPickerCoordinator) {
        removeChildCoordinator(coordinator, needToDismiss: true)
    }
    
    /// 선택한 연/월로 이동
    func changeYearMonth(_ coordinator: YearMonthPickerCoordinator, focusedYear: Int, focusedMonth: Int) {
        calendarVC.updateYearMonth(focusedYear: focusedYear, focusedMonth: focusedMonth)
        removeChildCoordinator(coordinator, needToDismiss: true)
    }
}

// MARK: - FilterCoordinator Methods
extension CalendarCoordinator {
    /// 선택한 필터 적용
    func applyFilter(_ coordinator: FilterCoordinator, filterWorkplace: WorkplaceSummary?) {
        calendarVC.updateFilter(filterWorkplace: filterWorkplace)
        removeChildCoordinator(coordinator, needToDismiss: true)
    }
}

// MARK: - CalendarWorkListCoordinator Methods
extension CalendarCoordinator {
    // TODO: 근무 엔티티를 직접 전달 or 근무 ID만 전달
    /// 근무 등록 화면 표시
    func showWorkerWorkRegister(work: WorkSummary?) {
        // TODO: - 근무 수정 화면 연결
        if let work {
            logger.debug("WorkRegisterVC 표시 - 근무 수정")
            dump(work)
        } else {
            let coordinator = WorkRegisterCoordinator(navigationController: navigationController, isOwnerInjected: false)
            childCoordinators.append(coordinator)
            coordinator.start()
        }
    }
    
    func showOwnerWorkRegister(work: WorkSummary?) {
        // TODO: - 근무 수정 화면 연결
        if let work {
            logger.debug("WorkRegisterVC 표시 - 근무 수정")
            dump(work)
        } else {
            let coordinator = WorkRegisterCoordinator(navigationController: navigationController, isOwnerInjected: true)
            childCoordinators.append(coordinator)
            coordinator.start()
        }
    }
    
    /// 캘린더 업데이트 요청
    func updateDataSource() {
        calendarVC.updateDataSource()
    }
}
