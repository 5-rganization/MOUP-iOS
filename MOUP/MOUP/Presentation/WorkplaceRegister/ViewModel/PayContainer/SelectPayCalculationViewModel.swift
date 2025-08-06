//
//  SelectPayCalculationViewModel.swift
//  MOUP
//
//  Created by 양원식 on 8/2/25.
//

import RxSwift
import RxCocoa

protocol SelectPayCalculationViewModelInput {
    var didSelectPayCalculation: AnyObserver<String> { get }
    var didTapConfirm: AnyObserver<Void> { get }
}

protocol SelectPayCalculationViewModelOutput {
    var isPayCalculationSelected: Driver<Bool> { get }
    var confirmedPayCalculation: Observable<String> { get }
    var selectedPayCalculation: Observable<String?> { get }
}

final class SelectPayCalculationViewModel: SelectPayCalculationViewModelInput, SelectPayCalculationViewModelOutput {
    
    private let didSelectPayCalculationSubject = PublishSubject<String>()
    private let didTapConfirmSubject = PublishSubject<Void>()

    private let selectedPayCalculationRelay = BehaviorRelay<String?>(value: nil)
    private let confirmedPayCalculationSubject = BehaviorRelay<String?>(value: nil)
    
    // Input
    var didSelectPayCalculation: AnyObserver<String> { didSelectPayCalculationSubject.asObserver() }
    var didTapConfirm: AnyObserver<Void> { didTapConfirmSubject.asObserver() }
    
    // Output
    var selectedPayCalculation: Observable<String?> { selectedPayCalculationRelay.asObservable() }
    var confirmedPayCalculation: Observable<String> {
        confirmedPayCalculationSubject
            .compactMap { $0 } // nil 제거
            .asObservable()
    }
    var isPayCalculationSelected: Driver<Bool> {
        selectedPayCalculationRelay
            .map { $0 != nil }
            .asDriver(onErrorJustReturn: false)
    }

    private let disposeBag = DisposeBag()

    init() {
        bind()
    }

    private func bind() {
        // 사용자가 버튼 클릭 시 선택 값 반영
        didSelectPayCalculationSubject
            .bind(to: selectedPayCalculationRelay)
            .disposed(by: disposeBag)

        // 완료 버튼 탭 시 확정
        didTapConfirmSubject
            .withLatestFrom(selectedPayCalculationRelay)
            .bind(to: confirmedPayCalculationSubject)
            .disposed(by: disposeBag)
    }

    func resetToConfirmedPayCalculationIfNeeded() {
        selectedPayCalculationRelay.accept(confirmedPayCalculationSubject.value)
    }
    
    func resetSelectedPayCalculation() {
        selectedPayCalculationRelay.accept(nil)
    }
}
