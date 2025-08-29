//
//  CalendarWorkListModalViewController.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

import RxCocoa
import RxSwift
import Then

/// `CalendarWorkListModalViewController`의 이벤트를 `CalendarWorkListCoordinator`에 전달하는 Delegate
protocol CalendarWorkListModalVCDelegate: AnyObject {
    /// `presentationControllerDidDismiss`를 감지했을 때 사용되는 메서드
    func dismissReceived()
    /// 캘린더에 업데이트가 필요할 때 사용되는 메서드
    func updateCalendarDataSource()
}

/// 근무 리스트 모달 VC
final class CalendarWorkListModalViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // Initializer Injections
    weak var coordinator: CalendarWorkListCoordinator?
    private let viewModel: CalendarWorkListViewModel
    private let selectedDay: Int
    private let calendarMode: CalendarMode
    
    // Property Injections
    weak var delegate: CalendarWorkListModalVCDelegate?
    
    // Input Relays
    private let deleteWorkIdRelay = PublishRelay<Int64>()
    
    // MARK: - UI Components
    private lazy var calendarWorkListView = CalendarWorkListView().then {
        $0.delegate = self
    }
    
    // MARK: - Initializer
    init(coordinator: CalendarWorkListCoordinator, viewModel: CalendarWorkListViewModel, selectedDay: Int, calendarMode: CalendarMode) {
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
        self.view = calendarWorkListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        calendarWorkListView.update(day: selectedDay)
    }
}

// MARK: - UI Methods
private extension CalendarWorkListModalViewController {
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
        let input = CalendarWorkListViewModel.Input(viewDidLoad: Observable.just(()), deleteWorkId: deleteWorkIdRelay.asObservable())
        let output = viewModel.transform(input: input)
        
        switch calendarMode {
        case .personal:
            output.calendarWorkList.asDriver(onErrorJustReturn: [])
                .drive(with: self, onNext: { owner, workList in
                    owner.calendarWorkListView.rx.emptyViewIsHidden.onNext(!workList.isEmpty)
                    owner.calendarWorkListView.rx.workTableViewIsHidden.onNext(workList.isEmpty)
                    owner.calendarWorkListView.rx.personalWorkTableViewDataSource.onNext(workList)
                })
                .disposed(by: disposeBag)
        case .shared:
            output.calendarWorkList.asDriver(onErrorJustReturn: [])
                .drive(with: self, onNext: { owner, workList in
                    owner.calendarWorkListView.rx.emptyViewIsHidden.onNext(!workList.isEmpty)
                    owner.calendarWorkListView.rx.workTableViewIsHidden.onNext(workList.isEmpty)
                    owner.calendarWorkListView.rx.sharedWorkTableViewDataSource.onNext(workList)
                })
                .disposed(by: disposeBag)
        }
    }
}

// MARK: - CalendarWorkListViewDelegate
extension CalendarWorkListModalViewController: CalendarWorkListViewDelegate {
    func editWork(work: CalendarWork) {
        // TODO: - 근무 수정 화면 연결
    }
    
    func deleteWork(id: Int64) {
        deleteWorkIdRelay.accept(id)
        delegate?.updateCalendarDataSource()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension CalendarWorkListModalViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.dismissReceived()
    }
}
