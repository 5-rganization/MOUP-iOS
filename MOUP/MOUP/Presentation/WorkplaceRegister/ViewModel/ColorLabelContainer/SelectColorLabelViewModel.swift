//
//  SelectColorLabelViewModel.swift
//  MOUP
//
//  Created by 양원식 on 8/4/25.
//

import RxSwift
import RxCocoa

protocol SelectColorLabelViewModelInput {
    var didSelectColor: AnyObserver<String> { get }
    var didTapConfirm: AnyObserver<Void> { get }
}

protocol SelectColorLabelViewModelOutput {
    var isColorSelected: Driver<Bool> { get }
    var confirmedColor: Observable<String> { get }
    var selectedColor: Observable<String?> { get }
}

final class SelectColorLabelViewModel: SelectColorLabelViewModelInput, SelectColorLabelViewModelOutput {

    // MARK: - Subjects & Relays
    private let didSelectColorSubject = PublishSubject<String>()
    private let didTapConfirmSubject = PublishSubject<Void>()

    private let selectedColorRelay = BehaviorRelay<String?>(value: nil)
    let confirmedColorRelay = BehaviorRelay<String?>(value: nil)

    private let disposeBag = DisposeBag()

    // MARK: - Input
    var didSelectColor: AnyObserver<String> { didSelectColorSubject.asObserver() }
    var didTapConfirm: AnyObserver<Void> { didTapConfirmSubject.asObserver() }

    // MARK: - Output
    var selectedColor: Observable<String?> {
        selectedColorRelay.asObservable()
    }

    var confirmedColor: Observable<String> {
        confirmedColorRelay
            .compactMap { $0 }
            .asObservable()
    }

    var isColorSelected: Driver<Bool> {
        selectedColorRelay
            .map { $0 != nil }
            .asDriver(onErrorJustReturn: false)
    }

    // MARK: - Init
    init() {
        bind()
    }

    // MARK: - Binding
    private func bind() {
        didSelectColorSubject
            .bind(to: selectedColorRelay)
            .disposed(by: disposeBag)

        didTapConfirmSubject
            .withLatestFrom(selectedColorRelay)
            .bind(to: confirmedColorRelay)
            .disposed(by: disposeBag)
    }

    // MARK: - Public Methods
    func resetToConfirmedColorIfNeeded() {
        selectedColorRelay.accept(confirmedColorRelay.value)
    }

    func resetSelectedColor() {
        selectedColorRelay.accept(nil)
    }
}
