//
//  CalendarEventListModalViewController.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

import RxCocoa
import RxSwift
import Then

/// `CalendarEventListModalViewController`의 이벤트를 `CalendarEventListCoordinator`에 알리는 Delegate
protocol CalendarEventListModalVCDelegate: AnyObject {
    func dismissGestureReceived()
}

/// 근무 리스트 모달 VC
final class CalendarEventListModalViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // Initializer Injections
    weak var coordinator: CalendarEventListCoordinator?
    private let viewModel: CalendarEventListViewModel
    private let selectedDay: Int
    private let calendarMode: CalendarMode
    
    // Property Injections
    weak var delegate: CalendarEventListModalVCDelegate?
    
    // MARK: - UI Components
    private let calendarEventListView = CalendarEventListView()
    
    // MARK: - Initializer
    init(coordinator: CalendarEventListCoordinator, viewModel: CalendarEventListViewModel, selectedDay: Int, calendarMode: CalendarMode) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        self.selectedDay = selectedDay
        self.calendarMode = calendarMode
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = calendarEventListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        calendarEventListView.update(day: selectedDay)
    }
}

// MARK: - UI Methods
private extension CalendarEventListModalViewController {
    func configure() {
        setStyles()
        setDelegates()
        setBindings()
    }
    
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
    
    func setDelegates() {
        self.presentationController?.delegate = self
    }
    
    func setBindings() {
        // ViewModel 바인딩
        let input = CalendarEventListViewModel.Input(viewDidLoad: Observable.just(()))
        let output = viewModel.transform(input: input)
        
        switch calendarMode {
        case .personal:
            output.calendarEventList.asDriver(onErrorJustReturn: [])
                .drive(calendarEventListView.rx.personalEventTableViewDataSource)
                .disposed(by: disposeBag)
        case .shared:
            output.calendarEventList.asDriver(onErrorJustReturn: [])
                .drive(calendarEventListView.rx.sharedEventTableViewDataSource)
                .disposed(by: disposeBag)
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension CalendarEventListModalViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.dismissGestureReceived()
    }
}
