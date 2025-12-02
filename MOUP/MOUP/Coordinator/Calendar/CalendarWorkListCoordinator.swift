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
    private let selectedDate: Date
    private let calendarWorkList: Observable<[WorkSummary]>
    private let calendarMode: CalendarMode
    
    
    // MARK: - Initializer
    init(parentCoordinator: CalendarCoordinator?, navigationController: UINavigationController, workUseCase: WorkUseCaseProtocol, selectedDate: Date, calendarWorkList: Observable<[WorkSummary]>, calendarMode: CalendarMode) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.workUseCase = workUseCase
        
        self.selectedDate = selectedDate
        self.calendarWorkList = calendarWorkList
        self.calendarMode = calendarMode
    }
    
    // MARK: - Coordinator Methods
    func start() {
        let calendarWorkListVM = CalendarWorkListViewModel(workUseCase: workUseCase, calendarWorkList: calendarWorkList)
        let calendarWorkListVC = CalendarWorkListModalViewController(coordinator: self, viewModel: calendarWorkListVM, selectedDate: selectedDate, calendarMode: calendarMode)
        
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
    func disappeared() {
        parentCoordinator?.disappeared(self)
    }
    
    func workerWorkCellTapped(work: WorkSummary) {
        parentCoordinator?.showWorkerWorkRegister(workToEdit: work)
    }
    
    func ownerWorkCellTapped(work: WorkSummary) {
        parentCoordinator?.showOwnerWorkRegister(workToEdit: work)
    }
    
    func workerEditButtonTapped(work: WorkSummary) {
        parentCoordinator?.dismissCalendarWorkList()
        parentCoordinator?.showWorkerWorkRegister(selectedDate: nil, workToEdit: work)
    }
    
    func ownerEditButtonTapped(work: WorkSummary) {
        parentCoordinator?.dismissCalendarWorkList()
        parentCoordinator?.showOwnerWorkRegister(workToEdit: work)
    }
    
    func workerWorkregisterButtonTapped(selectedDate: Date) {
        parentCoordinator?.dismissCalendarWorkList()
        parentCoordinator?.showWorkerWorkRegister(selectedDate: selectedDate, workToEdit: nil)
    }
    
    func ownerWorkregisterButtonTapped() {
        parentCoordinator?.dismissCalendarWorkList()
        parentCoordinator?.showOwnerWorkRegister(workToEdit: nil)
    }
    
    func updateCalendarDataSource() {
        parentCoordinator?.updateDataSource()
    }
}
