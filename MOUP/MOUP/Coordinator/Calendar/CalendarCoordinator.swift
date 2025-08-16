//
//  CalendarCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

import UIKit

final class CalendarCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController
    
    private lazy var calendarVM = CalendarViewModel()
    private lazy var calendarVC = CalendarViewController(coordinator: self, viewModel: calendarVM)
    
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Coordinator Methods
    func start() {
        navigationController.pushViewController(calendarVC, animated: false)
    }
    
    func showYearMonthPicker(currYear: Int, currMonth: Int) {
        let yearMonthCoordinator = YearMonthPickerCoordinator(navigationController: self.navigationController,
                                                              currYear: currYear,
                                                              currMonth: currMonth)
        yearMonthCoordinator.delegate = self
        yearMonthCoordinator.start()
        childCoordinators.append(yearMonthCoordinator)
    }
    
    func showFilter(calendarMode: CalendarMode) {
        let filterCoordinator = FilterCoordinator(navigationController: self.navigationController,
                                                  calendarMode: calendarMode)
        filterCoordinator.delegate = self
        filterCoordinator.start()
        childCoordinators.append(filterCoordinator)
    }
}

// MARK: - YearMonthCoordinatorDelegate
extension CalendarCoordinator: YearMonthPickerCoordinatorDelegate {
    func cancelled(_ coordinator: YearMonthPickerCoordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        navigationController.dismiss(animated: true)
    }
    
    func changeYearMonth(_ coordinator: YearMonthPickerCoordinator, focusedYear: Int, focusedMonth: Int) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        calendarVC.updateYearMonth(focusedYear: focusedYear, focusedMonth: focusedMonth)
        navigationController.dismiss(animated: true)
    }
}

// MARK: - FilterCoordinatorDelegate
extension CalendarCoordinator: FilterCoordinatorDelegate {
    func cancelled(_ coordinator: FilterCoordinator) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        navigationController.dismiss(animated: true)
    }
    
    func applyFilter(_ coordinator: FilterCoordinator, filter: FilterData?) {
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        
        navigationController.dismiss(animated: true)
    }
}
