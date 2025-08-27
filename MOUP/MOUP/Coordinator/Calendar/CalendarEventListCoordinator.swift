//
//  CalendarEventListCoordinator.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

/// `CalendarEventListCoordinator`의 화면 전환 이벤트를 `CalendarCoordinator`에 알리는 Delegate
protocol CalendarEventListCoordinatorDelegate: AnyObject {
    /// 근무 목록 화면 내림
    func dismissed(_ coordinator: CalendarEventListCoordinator)
}

/// `CalendarEventListModalViewController` Coordinator
final class CalendarEventListCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    
    // Initializer Injections
    private let navigationController: UINavigationController
    private let selectedDay: Int
    private let calendarEventList: [CalendarEvent]
    private let calendarMode: CalendarMode
    
    // Property Injections
    weak var delegate: CalendarEventListCoordinatorDelegate?
    
    // MARK: - Initializer
    init(navigationController: UINavigationController, selectedDay: Int, calendarEventList: [CalendarEvent], calendarMode: CalendarMode) {
        self.navigationController = navigationController
        self.selectedDay = selectedDay
        self.calendarEventList = calendarEventList
        self.calendarMode = calendarMode
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let calendarEventListVM = CalendarEventListViewModel(calendarEventList: calendarEventList)
        let calendarEventListVC = CalendarEventListModalViewController(coordinator: self, viewModel: calendarEventListVM, selectedDay: selectedDay, calendarMode: calendarMode)
        calendarEventListVC.delegate = self
        
        if let sheet = calendarEventListVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 0
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        navigationController.present(calendarEventListVC, animated: true)
    }
}

// MARK: - CalendarEventListModalVCDelegate
extension CalendarEventListCoordinator: CalendarEventListModalVCDelegate {
    func dismissGestureReceived() {
        delegate?.dismissed(self)
    }
}

