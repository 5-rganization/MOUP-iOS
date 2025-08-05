//
//  YearMonthPickerCoordinator.swift
//  MOUP
//
//  Created by 서동환 on 8/4/25.
//

import UIKit

/// `YearMonthPickerCoordinator`의 화면 전환 이벤트를 `CalendarCoordinator`에 알리는 Delegate
protocol YearMonthPickerCoordinatorDelegate: AnyObject {
    /// 연/월 이동 취소
    func cancelled(_ coordinator: YearMonthPickerCoordinator)
    /// 선택한 연/월로 이동
    func changeYearMonth(_ coordinator: YearMonthPickerCoordinator, focusedYear: Int, focusedMonth: Int)
}

final class YearMonthPickerCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    weak var delegate: YearMonthPickerCoordinatorDelegate?
    let navigationController: UINavigationController
    
    let currYear: Int
    let currMonth: Int
    
    // MARK: - Initialzier
    init(navigationController: UINavigationController,
         currYear: Int,
         currMonth: Int) {
        self.navigationController = navigationController
        self.currYear = currYear
        self.currMonth = currMonth
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let yearMonthPickerVC = YearMonthPickerViewController(currYear: currYear, currMonth: currMonth)
        yearMonthPickerVC.delegate = self
        
        if let sheet = yearMonthPickerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
        }
        
        navigationController.present(yearMonthPickerVC, animated: true)
    }
}

// MARK: - YearMonthPickerVCDelegate
extension YearMonthPickerCoordinator: YearMonthPickerVCDelegate {
    func dismissGestureReceived() {
        delegate?.cancelled(self)
    }
    
    func cancelButtonTapped() {
        delegate?.cancelled(self)
    }
    
    func gotoButtonTapped(focusedYear: Int, focusedMonth: Int) {
        delegate?.changeYearMonth(self, focusedYear: focusedYear, focusedMonth: focusedMonth)
    }
}
