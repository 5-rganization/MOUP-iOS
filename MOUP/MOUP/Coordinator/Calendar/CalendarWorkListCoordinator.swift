//
//  CalendarWorkListCoordinator.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

/// `CalendarWorkListCoordinator`의 이벤트를 `CalendarCoordinator`에 전달하는 Delegate
protocol CalendarWorkListCoordinatorDelegate: AnyObject {
    /// 근무 목록 화면 내림
    func dismissed(_ coordinator: CalendarWorkListCoordinator)
    // TODO: 근무 엔티티를 직접 전달 or 근무 ID만 전달
    /// 근무 등록 화면 표시
    func showWorkRegister(work: WorkSummary?)
    /// 캘린더 업데이트 요청
    func updateDataSource()
}

/// `CalendarWorkListModalViewController` Coordinator
final class CalendarWorkListCoordinator: Coordinator {
    
    // MARK: - Properties
    var childCoordinators = [Coordinator]()
    
    // Initializer Injections
    private let navigationController: UINavigationController
    private let workUseCase: WorkUseCaseProtocol
    private let selectedDay: Int
    private let calendarWorkList: [WorkSummary]
    private let calendarMode: CalendarMode
    
    // Property Injections
    weak var delegate: CalendarWorkListCoordinatorDelegate?
    
    // MARK: - Initializer
    init(navigationController: UINavigationController, workUseCase: WorkUseCaseProtocol, selectedDay: Int, calendarWorkList: [WorkSummary], calendarMode: CalendarMode) {
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
        calendarWorkListVC.delegate = self
        
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

// MARK: - CalendarWorkListModalVCDelegate
extension CalendarWorkListCoordinator: CalendarWorkListModalVCDelegate {
    func dismissReceived() {
        delegate?.dismissed(self)
    }
    
    func workCellTapped(work: WorkSummary) {
        delegate?.showWorkRegister(work: work)
    }
    
    func editButtonTapped(work: WorkSummary) {
        delegate?.showWorkRegister(work: work)
    }
    
    func registerButtonTapped() {
        delegate?.showWorkRegister(work: nil)
    }
    
    func updateCalendarDataSource() {
        delegate?.updateDataSource()
    }
}
