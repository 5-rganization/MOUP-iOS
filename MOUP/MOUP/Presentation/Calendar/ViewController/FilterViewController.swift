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
    func applyButtonTapped(model: FilterModel?)
}

/// 필터 VC
final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: FilterVCDelegate?
    private let disposeBag = DisposeBag()
    
    private let viewModel: FilterViewModel
    
    // MARK: - UI Components
    private let filterView = FilterView()
    
    // MARK: - Initializer
    init(viewModel: FilterViewModel) {
        self.viewModel = viewModel
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
        
        viewModel.viewDidLoad.onNext(())
    }
}

private extension FilterViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setDelegates()
        setBinding()
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.view.backgroundColor = .primaryBackground
    }
    
    // MARK: - setDelegates
    func setDelegates() {
        self.presentationController?.delegate = self
    }
    
    // MARK: - setBinding
    func setBinding() {
        // Child View Binding
        filterView.rx.applyButtonTap.asDriver()
            .drive(with: self, onNext: { owner, _ in
                owner.delegate?.applyButtonTapped(model: nil)
            }).disposed(by: disposeBag)
        
        // Inputs
        filterView.rx.applyButtonTap
            .bind(to: viewModel.applyButtonTapped)
            .disposed(by: disposeBag)
        
        // Outputs
        viewModel.filterList.asDriver(onErrorJustReturn: [])
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
