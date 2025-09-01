//
//  FilterCoordinator.swift
//  MOUP
//
//  Created by 서동환 on 8/4/25.
//

import UIKit

/// `FilterCoordinator`의 화면 전환 이벤트를 `CalendarCoordinator`에 알리는 Delegate
protocol FilterCoordinatorDelegate: AnyObject {
    func cancelled(_ coordinator: FilterCoordinator)
    func applyFilter(_ coordinator: FilterCoordinator, filterWorkplace: FilterWorkplace?)
}

/// 캘린더 ➡️ 필터 Coordinator
final class FilterCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    
    // Initializer Injections
    private let navigationController: UINavigationController
    private let calendarMode: CalendarMode
    private let selectedFilterWorkplace: FilterWorkplace?
    
    // Property Injections
    weak var delegate: FilterCoordinatorDelegate?
    
    // MARK: - Initializer
    init(navigationController: UINavigationController, calendarMode: CalendarMode, selectedFilterWorkplace: FilterWorkplace?) {
        self.navigationController = navigationController
        self.calendarMode = calendarMode
        self.selectedFilterWorkplace = selectedFilterWorkplace
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let filterVM = FilterViewModel()
        let filterVC = FilterViewController(viewModel: filterVM, calendarMode: calendarMode, selectedFilterWorkplace: selectedFilterWorkplace)
        filterVC.delegate = self
        
        if let sheet = filterVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
        }
        
        navigationController.present(filterVC, animated: true)
    }
}

// MARK: - FilterVCDelegate
extension FilterCoordinator: FilterVCDelegate {
    func dismissGestureReceived() {
        delegate?.cancelled(self)
    }
    
    func applyButtonTapped(filterWorkplace: FilterWorkplace?) {
        delegate?.applyFilter(self, filterWorkplace: filterWorkplace)
    }
}
