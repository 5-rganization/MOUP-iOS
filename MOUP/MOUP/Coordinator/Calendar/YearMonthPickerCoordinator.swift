//
//  YearMonthPickerCoordinator.swift
//  MOUP
//
//  Created by 서동환 on 8/4/25.
//

import UIKit

/// `YearMonthPickerCoordinator`의 이벤트를 `CalendarCoordinator`에 전달하는 Delegate
protocol YearMonthPickerCoordinatorDelegate: AnyObject {
    /// 연/월 Picker 화면 내림
    func dismissed(_ coordinator: YearMonthPickerCoordinator)
    /// 연/월 이동 취소
    func cancelled(_ coordinator: YearMonthPickerCoordinator)
    /// 선택한 연/월로 이동
    func changeYearMonth(_ coordinator: YearMonthPickerCoordinator, focusedYear: Int, focusedMonth: Int)
}

/// `YearMonthPickerModalViewController` Coordinator
final class YearMonthPickerCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    
    // Initializer Injections
    private let navigationController: UINavigationController
    private let currYear: Int
    private let currMonth: Int
    
    // Property Injections
    weak var delegate: YearMonthPickerCoordinatorDelegate?
    
    // MARK: - Initialzier
    init(navigationController: UINavigationController, currYear: Int, currMonth: Int) {
        self.navigationController = navigationController
        self.currYear = currYear
        self.currMonth = currMonth
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let yearMonthPickerVC = YearMonthPickerModalViewController(currYear: currYear, currMonth: currMonth)
        yearMonthPickerVC.delegate = self
        
        if let sheet = yearMonthPickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
        }
        
        navigationController.present(yearMonthPickerVC, animated: true)
    }
}

// MARK: - YearMonthPickerModalVCDelegate
extension YearMonthPickerCoordinator: YearMonthPickerModalVCDelegate {
    func dismissReceived() {
        delegate?.dismissed(self)
    }
    
    func cancelButtonTapped() {
        delegate?.cancelled(self)
    }
    
    func gotoButtonTapped(focusedYear: Int, focusedMonth: Int) {
        delegate?.changeYearMonth(self, focusedYear: focusedYear, focusedMonth: focusedMonth)
    }
}
