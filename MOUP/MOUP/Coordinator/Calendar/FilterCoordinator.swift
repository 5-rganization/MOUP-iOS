//
//  FilterCoordinator.swift
//  MOUP
//
//  Created by 서동환 on 8/4/25.
//

import UIKit

/// `FilterCoordinator`의 이벤트를 `CalendarCoordinator`에 전달하는 Delegate
protocol FilterCoordinatorDelegate: AnyObject {
    /// 필터 선택 화면 내림
    func dismissed(_ coordinator: FilterCoordinator)
    /// 선택한 필터 적용
    func applyFilter(_ coordinator: FilterCoordinator, filterWorkplace: WorkplaceSummary?)
}

/// `FilterModalViewController` Coordinator
final class FilterCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    
    // Initializer Injections
    private let navigationController: UINavigationController
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let calendarMode: CalendarMode
    private let selectedFilterWorkplace: WorkplaceSummary?
    
    // Property Injections
    weak var delegate: FilterCoordinatorDelegate?
    
    // MARK: - Initializer
    init(navigationController: UINavigationController, workplaceUseCase: WorkplaceUseCaseProtocol, calendarMode: CalendarMode, selectedFilterWorkplace: WorkplaceSummary?) {
        self.navigationController = navigationController
        self.workplaceUseCase = workplaceUseCase
        
        self.calendarMode = calendarMode
        self.selectedFilterWorkplace = selectedFilterWorkplace
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let filterVM = FilterViewModel(workplaceUseCase: workplaceUseCase)
        let filterVC = FilterModalViewController(viewModel: filterVM, calendarMode: calendarMode, selectedFilterWorkplace: selectedFilterWorkplace)
        filterVC.delegate = self
        
        if let sheet = filterVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 12
        }
        
        navigationController.present(filterVC, animated: true)
    }
}

// MARK: - FilterModalVCDelegate
extension FilterCoordinator: FilterModalVCDelegate {
    func dismissReceived() {
        delegate?.dismissed(self)
    }
    
    func applyButtonTapped(filterWorkplace: WorkplaceSummary?) {
        delegate?.applyFilter(self, filterWorkplace: filterWorkplace)
    }
}
