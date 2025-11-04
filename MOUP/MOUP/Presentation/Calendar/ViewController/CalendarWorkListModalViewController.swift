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
    /// 근무 목록 셀을 탭했을 때 사용되는 메서드
    func workCellTapped(work: WorkSummary)
    /// 수정하기 버튼을 탭했을 때 사용되는 메서드
    func editButtonTapped(work: WorkSummary)
    /// 근무 등록하기 버튼을 탭했을 때 사용되는 메서드
    func registerButtonTapped()
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
    private let deleteSingleWorkIdRelay = PublishRelay<Int>()
    private let deleteRecurringWorkIdRelay = PublishRelay<Int>()
    
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
        // View 바인딩
        calendarWorkListView.rx.workTableViewModelSelected.asDriver()
            .drive(with: self) { owner, work in
                owner.coordinator?.workCellTapped(work: work)
            }.disposed(by: disposeBag)
        
        calendarWorkListView.rx.registerButtonTap.asDriver()
            .drive(with: self) { owner, _ in
                owner.coordinator?.registerButtonTapped()
            }.disposed(by: disposeBag)
        
        // ViewModel 바인딩
        let input = CalendarWorkListViewModel.Input(viewDidLoad: Observable.just(()),
                                                    deleteSingleWorkId: deleteSingleWorkIdRelay.asObservable(),
                                                    deleteRecurringWorkId: deleteRecurringWorkIdRelay.asObservable())
        let output = viewModel.transform(input: input)
        
        output.calendarWorkList.asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { owner, workList in
                owner.calendarWorkListView.rx.emptyLabelIsHidden.onNext(!workList.isEmpty)
                owner.calendarWorkListView.rx.workTableViewIsHidden.onNext(workList.isEmpty)
                
                switch owner.calendarMode {
                case .personal:
                    owner.calendarWorkListView.rx.personalWorkTableViewDataSource.onNext(workList)
                case .shared:
                    owner.calendarWorkListView.rx.sharedWorkTableViewDataSource.onNext(workList)
                }
            }).disposed(by: disposeBag)
        
        output.errorMessage.asDriver(onErrorJustReturn: (title: "오류 발생", message: "잠시 후 다시 시도해주세요."))
            .drive(with: self) { owner, errorMessage in
                owner.presentNoticeModal(title: errorMessage.title, comment: errorMessage.message)
            }.disposed(by: disposeBag)
    }
}

// MARK: - CalendarWorkListViewDelegate
extension CalendarWorkListModalViewController: CalendarWorkListViewDelegate {
    func editWork(work: WorkSummary) {
        delegate?.editButtonTapped(work: work)
    }
    
    func deleteSingleWork(workId: Int) {
        deleteSingleWorkIdRelay.accept(workId)
        delegate?.updateCalendarDataSource()
    }
    
    func deleteRecurringWork(workId: Int) {
        deleteRecurringWorkIdRelay.accept(workId)
        delegate?.updateCalendarDataSource()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension CalendarWorkListModalViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.dismissReceived()
    }
}
