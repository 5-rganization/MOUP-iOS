//
//  FilterViewModel.swift
//  MOUP
//
//  Created by 서동환 on 8/3/25.
//

import Foundation

import RxRelay
import RxSwift

/// 필터 VM Input
protocol FilterViewModelInput {
    var viewDidLoad: AnyObserver<Void> { get }
    var applyButtonTapped: AnyObserver<Void> { get }
}

/// 필터 VM Output
protocol FilterViewModelOutput {
    var filterList: Observable<[FilterModel]> { get }
}

/// 필터 VM
final class FilterViewModel: FilterViewModelInput, FilterViewModelOutput {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Inputs
    private let applyButtonTappedSubject = PublishSubject<Void>()
    private let viewDidLoadSubject = PublishSubject<Void>()
    
    var viewDidLoad: AnyObserver<Void> { viewDidLoadSubject.asObserver() }
    var applyButtonTapped: AnyObserver<Void> { applyButtonTappedSubject.asObserver() }
    
    // MARK: - Outputs
    private let filterListRelay = BehaviorRelay<[FilterModel]>(value: [])
    
    var filterList: Observable<[FilterModel]>
    
    // MARK: - Initializer
    init() {
        self.filterList = filterListRelay.asObservable()
        
        bind()
    }
}

private extension FilterViewModel {
    // MARK: - Bind Input/Output
    func bind() {
        viewDidLoadSubject
            .subscribe(with: self) { owner, _ in
                // 사용자의 근무지/매장 불러오기
                owner.filterListRelay.accept([FilterModel(workplaceId: "test", workplaceName: "테스트")])
            }.disposed(by: disposeBag)
        
        applyButtonTappedSubject
            .subscribe(with: self) { owner, _ in
                
            }.disposed(by: disposeBag)
    }
}
