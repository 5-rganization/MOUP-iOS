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
    func applyFilter(_ coordinator: FilterCoordinator, filter: FilterData?)
}

final class FilterCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    weak var delegate: FilterCoordinatorDelegate?
    
    let navigationController: UINavigationController
    let calendarMode: CalendarMode
    
    // MARK: - Initializer
    init(navigationController: UINavigationController, calendarMode: CalendarMode) {
        self.navigationController = navigationController
        self.calendarMode = calendarMode
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let filterVM = FilterViewModel()
        let filterVC = FilterViewController(viewModel: filterVM, calendarMode: calendarMode)
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
    
    func applyButtonTapped(filter: FilterData?) {
        delegate?.applyFilter(self, filter: filter)
    }
}
