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
    
    private lazy var calendarVC = CalendarViewController(coordinator: self)
    
    // MARK: - Initializer
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Coordinator Methods
    func start() {
        navigationController.pushViewController(calendarVC, animated: false)
    }
    
    func showYearMonthPickerVC(currYear: Int, currMonth: Int) {
        let yearMonthCoordinator = YearMonthPickerCoordinator(navigationController: self.navigationController,
                                                              currYear: currYear,
                                                              currMonth: currMonth)
        yearMonthCoordinator.delegate = self
        yearMonthCoordinator.start()
        childCoordinators.append(yearMonthCoordinator)
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

