//
//  OLDWorkBreakPickerViewModel.swift
//  MOUP
//
//  Created by 양원식 on 9/16/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol OLDWorkBreakPickerViewModelInput {
    var didTapConfirm: AnyObserver<Void> { get }
    var didTapCancel: AnyObserver<Void> { get }
    var selectedIndex: AnyObserver<Int> { get }
    func resetToConfirmedIndex()
}

protocol OLDWorkBreakPickerViewModelOutput {
    var currentIndex: Driver<Int> { get }
    var confirmSelectedBreak: Observable<Int> { get } // 분 단위 결과
    var dismiss: Observable<Void> { get }
}

final class OLDWorkBreakPickerViewModel: OLDWorkBreakPickerViewModelInput, OLDWorkBreakPickerViewModelOutput {
    
    private let indexRelay: BehaviorRelay<Int>
    private let confirmedIndexRelay: BehaviorRelay<Int>
    
    private let didTapConfirmSubject = PublishSubject<Void>()
    private let didTapCancelSubject = PublishSubject<Void>()
    private let selectedIndexSubject = PublishSubject<Int>()
    
    var didTapConfirm: AnyObserver<Void> { didTapConfirmSubject.asObserver() }
    var didTapCancel: AnyObserver<Void> { didTapCancelSubject.asObserver() }
    var selectedIndex: AnyObserver<Int> { selectedIndexSubject.asObserver() }
    
    func resetToConfirmedIndex() {
        indexRelay.accept(confirmedIndexRelay.value)
    }
    
    var currentIndex: Driver<Int> { indexRelay.asDriver() }
    var dismiss: Observable<Void> { didTapCancelSubject.asObservable() }
    
    lazy var confirmSelectedBreak: Observable<Int> = {
        return didTapConfirmSubject
            .withLatestFrom(indexRelay)
            .do(onNext: { [weak self] idx in self?.confirmedIndexRelay.accept(idx) })
            .map { $0 * 30 } // 30분 단위
            .share()
    }()
    
    private let disposeBag = DisposeBag()
    
    init(initialIndex: Int = 0) {
        indexRelay = BehaviorRelay(value: initialIndex)
        confirmedIndexRelay = BehaviorRelay(value: initialIndex)
        
        selectedIndexSubject.bind(to: indexRelay).disposed(by: disposeBag)
    }
}
extension OLDWorkBreakPickerViewModel {
    func setInitialBreak(_ minutes: Int) {
        let index = minutes / 30
        indexRelay.accept(index)
        confirmedIndexRelay.accept(index)
    }
}
