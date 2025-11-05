//
//  FilterCoordinator.swift
//  MOUP
//
//  Created by 서동환 on 8/4/25.
//

import UIKit

/// `FilterModalViewController` Coordinator
final class FilterCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    
    // Initializer Injections
    weak var parentCoordinator: CalendarCoordinator?
    private let navigationController: UINavigationController
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let calendarMode: CalendarMode
    private let selectedFilterWorkplace: WorkplaceSummary?
    
    // MARK: - Initializer
    init(parentCoordinator: CalendarCoordinator?, navigationController: UINavigationController, workplaceUseCase: WorkplaceUseCaseProtocol, calendarMode: CalendarMode, selectedFilterWorkplace: WorkplaceSummary?) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.workplaceUseCase = workplaceUseCase
        
        self.calendarMode = calendarMode
        self.selectedFilterWorkplace = selectedFilterWorkplace
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let filterVM = FilterViewModel(workplaceUseCase: workplaceUseCase)
        let filterVC = FilterModalViewController(coordinator: self, viewModel: filterVM, calendarMode: calendarMode, selectedFilterWorkplace: selectedFilterWorkplace)
        
        if let sheet = filterVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
        }
        
        navigationController.present(filterVC, animated: true)
    }
}

// MARK: - Parent Coordinator Methods
extension FilterCoordinator {
    func dismissReceived() {
        parentCoordinator?.dismissed(self)
    }
    
    func applyButtonTapped(filterWorkplace: WorkplaceSummary?) {
        parentCoordinator?.applyFilter(self, filterWorkplace: filterWorkplace)
    }
}
