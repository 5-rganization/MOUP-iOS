//
//  SelectPayTypeViewModel.swift
//  MOUP
//
//  Created by 양원식 on 8/2/25.
//

import RxSwift
import RxCocoa

protocol SelectPayTypeViewModelInput {
    var didSelectPayType: AnyObserver<String> { get }
    var didTapConfirm: AnyObserver<Void> { get }
}

protocol SelectPayTypeViewModelOutput {
    var isPayTypeSelected: Driver<Bool> { get }
    var confirmedPayType: Observable<String> { get }
    var selectedPayType: Observable<String?> { get }
}

final class SelectPayTypeViewModel: SelectPayTypeViewModelInput, SelectPayTypeViewModelOutput {

    // MARK: - Properties
    private let didSelectPayTypeSubject = PublishSubject<String>()
    private let didTapConfirmSubject = PublishSubject<Void>()

    let selectedPayTypeRelay = BehaviorRelay<String?>(value: nil)
    let confirmedPayTypeSubject = BehaviorRelay<String?>(value: nil)

    // Input
    var didSelectPayType: AnyObserver<String> { didSelectPayTypeSubject.asObserver() }
    var didTapConfirm: AnyObserver<Void> { didTapConfirmSubject.asObserver() }

    // Output
    var selectedPayType: Observable<String?> { selectedPayTypeRelay.asObservable() }
    var confirmedPayType: Observable<String> {
        confirmedPayTypeSubject
            .compactMap { $0 }
            .asObservable()
    }
    var isPayTypeSelected: Driver<Bool> {
        selectedPayTypeRelay
            .map { $0 != nil }
            .asDriver(onErrorJustReturn: false)
    }

    private let disposeBag = DisposeBag()

    init() {
        bind()
    }

    private func bind() {
        didSelectPayTypeSubject
            .bind(to: selectedPayTypeRelay)
            .disposed(by: disposeBag)

        didTapConfirmSubject
            .withLatestFrom(selectedPayTypeRelay)
            .bind(to: confirmedPayTypeSubject)
            .disposed(by: disposeBag)
    }

    func resetToConfirmedPayTypeIfNeeded() {
        selectedPayTypeRelay.accept(confirmedPayTypeSubject.value)
    }

    func resetSelectedPayType() {
        selectedPayTypeRelay.accept(nil)
    }
}
