//
//  CalendarWorkListCoordinator.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

import RxSwift

/// `CalendarWorkListModalViewController` Coordinator
final class CalendarWorkListCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    
    // Initializer Injections
    weak var parentCoordinator: CalendarCoordinator?
    private let navigationController: UINavigationController
    private let workUseCase: WorkUseCaseProtocol
    private let selectedDay: Int
    private let calendarWorkList: Observable<[WorkSummary]>
    private let calendarMode: CalendarMode
    
    
    // MARK: - Initializer
    init(parentCoordinator: CalendarCoordinator?, navigationController: UINavigationController, workUseCase: WorkUseCaseProtocol, selectedDay: Int, calendarWorkList: Observable<[WorkSummary]>, calendarMode: CalendarMode) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.workUseCase = workUseCase
        
        self.selectedDay = selectedDay
        self.calendarWorkList = calendarWorkList
        self.calendarMode = calendarMode
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let calendarWorkListVM = CalendarWorkListViewModel(workUseCase: workUseCase, calendarWorkList: calendarWorkList)
        let calendarWorkListVC = CalendarWorkListModalViewController(coordinator: self, viewModel: calendarWorkListVM, selectedDay: selectedDay, calendarMode: calendarMode)
        
        if let sheet = calendarWorkListVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 0
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        navigationController.present(calendarWorkListVC, animated: true)
    }
}

// MARK: - Parent Coordinator Methods
extension CalendarWorkListCoordinator {
    func dismissReceived() {
        parentCoordinator?.dismissed(self)
    }
    
    func workCellTapped(work: WorkSummary) {
        parentCoordinator?.showWorkRegister(work: work)
    }
    
    func editButtonTapped(work: WorkSummary) {
        parentCoordinator?.dismissed(self)
        parentCoordinator?.showWorkRegister(work: work)
    }
    
    func registerButtonTapped() {
        parentCoordinator?.dismissed(self)
        parentCoordinator?.showWorkRegister(work: nil)
    }
    
    func updateCalendarDataSource() {
        parentCoordinator?.updateDataSource()
    }
}
