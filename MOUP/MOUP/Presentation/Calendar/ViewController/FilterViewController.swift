//
//  FilterViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/31/25.
//

import UIKit

import RxCocoa
import RxSwift

/// `FilterViewController`의 이벤트를 `FilterCoordinator`에 알리는 Delegate
protocol FilterVCDelegate: AnyObject {
    func dismissGestureReceived()
    func applyButtonTapped(filter: FilterData?)
}

/// 필터 VC
final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // Initializer Injections
    private let viewModel: FilterViewModel
    private let calendarMode: CalendarMode
    
    // Property Injections
    weak var delegate: FilterVCDelegate?
    
    // Input Relays
    private let viewDidLoadRelay = PublishRelay<CalendarMode>()
    
    // MARK: - UI Components
    private let filterView = FilterView()
    
    // MARK: - Initializer
    init(viewModel: FilterViewModel, calendarMode: CalendarMode) {
        self.viewModel = viewModel
        self.calendarMode = calendarMode
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = filterView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        viewDidLoadRelay.accept(calendarMode)
    }
}

private extension FilterViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setDelegates()
        setBindings()
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
    
    // MARK: - setDelegates
    func setDelegates() {
        self.presentationController?.delegate = self
    }
    
    // MARK: - setBindings
    func setBindings() {
        // View 바인딩
        filterView.rx.applyButtonTap.asDriver()
            .drive(with: self, onNext: { owner, _ in
                owner.delegate?.applyButtonTapped(filter: nil)
            }).disposed(by: disposeBag)
        
        // ViewModel 바인딩
        let input = FilterViewModel.Input(viewDidLoad: viewDidLoadRelay.asObservable())
        let output = viewModel.transform(input: input)
        
        output.filterDataList.asDriver(onErrorJustReturn: [])
            .drive(filterView.rx.filterTableViewDataSource)
            .disposed(by: disposeBag)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension FilterViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.dismissGestureReceived()
    }
}
