//
//  YearMonthPickerCoordinator.swift
//  MOUP
//
//  Created by 서동환 on 8/4/25.
//

import UIKit

/// `YearMonthPickerModalViewController` Coordinator
final class YearMonthPickerCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    
    // Initializer Injections
    weak var parentCoordinator: CalendarCoordinator?
    private let navigationController: UINavigationController
    private let currYear: Int
    private let currMonth: Int
    
    // MARK: - Initialzier
    init(parentCoordinator: CalendarCoordinator?, navigationController: UINavigationController, currYear: Int, currMonth: Int) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.currYear = currYear
        self.currMonth = currMonth
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let yearMonthPickerVC = YearMonthPickerModalViewController(coordinator: self, currYear: currYear, currMonth: currMonth)
        
        if let sheet = yearMonthPickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
        }
        
        navigationController.present(yearMonthPickerVC, animated: true)
    }
}

// MARK: - Parent Coordinator Methods
extension YearMonthPickerCoordinator {
    func disappeared() {
        parentCoordinator?.disappeared(self)
    }
    
    func cancelButtonTapped() {
        parentCoordinator?.cancelled(self)
    }
    
    func gotoButtonTapped(focusedYear: Int, focusedMonth: Int) {
        parentCoordinator?.changeYearMonth(self, focusedYear: focusedYear, focusedMonth: focusedMonth)
    }
}
