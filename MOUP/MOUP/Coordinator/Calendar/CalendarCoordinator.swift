//
//  CalendarCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

import UIKit

/// `CalendarViewController` Coordinator
final class CalendarCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    private lazy var calendarVM = CalendarViewModel()
    private lazy var calendarVC = CalendarViewController(coordinator: self, viewModel: calendarVM)
    
    // Initializer Injections
    private let navigationController: UINavigationController
    
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Coordinator Methods
    func start() {
        navigationController.pushViewController(calendarVC, animated: false)
    }
    
    func showYearMonthPicker(currYear: Int, currMonth: Int) {
        let yearMonthCoordinator = YearMonthPickerCoordinator(navigationController: navigationController,
                                                              currYear: currYear,
                                                              currMonth: currMonth)
        yearMonthCoordinator.delegate = self
        yearMonthCoordinator.start()
        childCoordinators.append(yearMonthCoordinator)
    }
    
    func showFilter(calendarMode: CalendarMode, selectedFilterWorkplace: FilterWorkplace?) {
        let filterCoordinator = FilterCoordinator(navigationController: navigationController,
                                                  calendarMode: calendarMode,
                                                  selectedFilterWorkplace: selectedFilterWorkplace)
        filterCoordinator.delegate = self
        filterCoordinator.start()
        childCoordinators.append(filterCoordinator)
    }
    
    func showCalendarEventList(selectedDay: Int, calendarEventList: [CalendarEvent], calendarMode: CalendarMode) {
        let calendarEventListCoordinator = CalendarEventListCoordinator(navigationController: navigationController,
                                                                        selectedDay: selectedDay,
                                                                        calendarEventList: calendarEventList,
                                                                        calendarMode: calendarMode)
        calendarEventListCoordinator.delegate = self
        calendarEventListCoordinator.start()
        childCoordinators.append(calendarEventListCoordinator)
    }
    
    func dismissCalendarEventList() {
        guard let coordinator = childCoordinators.first(where: { $0 is CalendarEventListCoordinator }) else {
            fatalError("dismissCalendarEventList() 메서드 실행 실패 - childCoordinators에 CalendarEventListCoordinator가 존재하지 않습니다.")
        }
        removeChildCoordinator(coordinator, needToDismiss: true)
    }
}

// MARK: - YearMonthCoordinatorDelegate
extension CalendarCoordinator: YearMonthPickerCoordinatorDelegate {
    func dismissed(_ coordinator: YearMonthPickerCoordinator) {
        removeChildCoordinator(coordinator, needToDismiss: false)
    }
    
    func cancelled(_ coordinator: YearMonthPickerCoordinator) {
        removeChildCoordinator(coordinator, needToDismiss: true)
    }
    
    func changeYearMonth(_ coordinator: YearMonthPickerCoordinator, focusedYear: Int, focusedMonth: Int) {
        calendarVC.updateYearMonth(focusedYear: focusedYear, focusedMonth: focusedMonth)
        removeChildCoordinator(coordinator, needToDismiss: true)
    }
}

// MARK: - FilterCoordinatorDelegate
extension CalendarCoordinator: FilterCoordinatorDelegate {
    func dismissed(_ coordinator: FilterCoordinator) {
        removeChildCoordinator(coordinator, needToDismiss: false)
    }
    
    func applyFilter(_ coordinator: FilterCoordinator, filterWorkplace: FilterWorkplace?) {
        calendarVC.updateFilter(filterWorkplace: filterWorkplace)
        removeChildCoordinator(coordinator, needToDismiss: true)
    }
}

// MARK: - CalendarEventListCoordinatorDelegate
extension CalendarCoordinator: CalendarEventListCoordinatorDelegate {
    func dismissed(_ coordinator: CalendarEventListCoordinator) {
        removeChildCoordinator(coordinator, needToDismiss: false)
    }
}

private extension CalendarCoordinator {
    func removeChildCoordinator(_ coordinator: Coordinator, needToDismiss: Bool) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        if needToDismiss {
            navigationController.dismiss(animated: true)
        }
    }
}
