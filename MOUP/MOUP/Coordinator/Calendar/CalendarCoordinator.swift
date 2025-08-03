//
//  CalendarCoordinator.swift
//  MOUP
//
//  Created by 양원식 on 7/14/25.
//

import UIKit

final class CalendarCoordinator: CalendarCoordinatorProtocol {
    var childCoordinators = [Coordinator]()
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let calendarVC = CalendarViewController(coordinator: self)
        navigationController.pushViewController(calendarVC, animated: false)
    }
    
    func showYearMonthPicker(currYear: Int, currMonth: Int, delegate: YearMonthPickerVCDelegate) {
        let yearMonthPickerVC = YearMonthPickerViewController(currYear: currYear, currMonth: currMonth)
        yearMonthPickerVC.delegate = delegate
        
        if let sheet = yearMonthPickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
        }
        
        navigationController.present(yearMonthPickerVC, animated: true)
    }
}
