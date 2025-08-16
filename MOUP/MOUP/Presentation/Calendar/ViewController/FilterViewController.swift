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
    func applyButtonTapped(filterWorkplace: FilterWorkplace?)
}

/// 필터 VC
final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // Initializer Injections
    private let viewModel: FilterViewModel
    private let calendarMode: CalendarMode
    private var selectedFilterWorkplace: FilterWorkplace?
    
    // Property Injections
    weak var delegate: FilterVCDelegate?
    
    // MARK: - UI Components
    private let filterView = FilterView()
    
    // MARK: - Initializer
    init(viewModel: FilterViewModel, calendarMode: CalendarMode, selectedFilterWorkplace: FilterWorkplace?) {
        self.viewModel = viewModel
        self.calendarMode = calendarMode
        self.selectedFilterWorkplace = selectedFilterWorkplace
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
        filterView.rx.filterWorkplaceTableViewModelSelected
            .subscribe(with: self) { owner, filterWorkplace in
                if filterWorkplace.workplaceId != -1 {
                    owner.selectedFilterWorkplace = filterWorkplace
                } else {
                    // 전체 보기
                    owner.selectedFilterWorkplace = nil
                }
            }.disposed(by: disposeBag)
        
        filterView.rx.applyButtonTap.asDriver()
            .drive(with: self, onNext: { owner, _ in
                owner.delegate?.applyButtonTapped(filterWorkplace: owner.selectedFilterWorkplace)
            }).disposed(by: disposeBag)
        
        // ViewModel 바인딩
        let input = FilterViewModel.Input(viewDidLoad: Observable.just(calendarMode))
        let output = viewModel.transform(input: input)
        
        output.filterWorkplaceList.asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { owner, filterWorkplaceList in
                owner.filterView.rx.filterWorkplaceTableViewDataSource.onNext(filterWorkplaceList)
                
                // 초기 셀 선택 로직
                if owner.selectedFilterWorkplace == nil {
                    owner.setDefaultSelect(firstOfList: filterWorkplaceList.first)
                } else {
                    if let selectedIndex = filterWorkplaceList.firstIndex(where: { $0.workplaceId == owner.selectedFilterWorkplace?.workplaceId }) {
                        owner.filterView.selectRow(at: IndexPath(row: selectedIndex, section: 0))
                    } else {
                        owner.setDefaultSelect(firstOfList: filterWorkplaceList.first)
                    }
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Private Methods
private extension FilterViewController {
    func setDefaultSelect(firstOfList filterWorkplace: FilterWorkplace?) {
        if filterWorkplace?.workplaceId == -1 {
            selectedFilterWorkplace = nil
        } else {
            selectedFilterWorkplace = filterWorkplace
        }
        filterView.selectRow(at: IndexPath(row: 0, section: 0))
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension FilterViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.dismissGestureReceived()
    }
}
