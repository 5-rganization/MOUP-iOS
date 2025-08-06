//
//  PayDayPickerViewModel.swift
//  MOUP
//
//  Created by 양원식 on 8/4/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol PayDayPickerViewModelInput {
    var didTapConfirm: AnyObserver<Void> { get }
    var didTapCancel: AnyObserver<Void> { get }
    var selectedDay: AnyObserver<Int> { get }
}

protocol PayDayPickerViewModelOutput {
    var currentDay: Driver<Int> { get }
    var confirmSelectedDay: Observable<Int> { get }
    var dismiss: Observable<Void> { get }
}

final class PayDayPickerViewModel: PayDayPickerViewModelInput, PayDayPickerViewModelOutput {

    // MARK: - Input
    private let selectedDayRelay = BehaviorRelay<Int>(value: Calendar.current.component(.day, from: Date()))
    private let didTapConfirmSubject = PublishSubject<Void>()
    private let didTapCancelSubject = PublishSubject<Void>()

    var didTapConfirm: AnyObserver<Void> { didTapConfirmSubject.asObserver() }
    var didTapCancel: AnyObserver<Void> { didTapCancelSubject.asObserver() }

    var selectedDay: AnyObserver<Int> {
        AnyObserver { [weak self] event in
            guard let value = event.element else { return }
            self?.selectedDayRelay.accept(value)
        }
    }

    // MARK: - Output
    var currentDay: Driver<Int> {
        selectedDayRelay.asDriver()
    }

    var confirmSelectedDay: Observable<Int> {
        didTapConfirmSubject
            .map { [weak self] in
                self?.selectedDayRelay.value ?? 1
            }
            .do(onNext: { [weak self] value in
                self?.confirmedDay = value
            })
    }

    var dismiss: Observable<Void> {
        didTapCancelSubject.asObservable()
    }

    // MARK: - Private
    private var confirmedDay: Int

    // MARK: - Init
    init(initialDay: Int? = nil) {
        let startDay = initialDay ?? Calendar.current.component(.day, from: Date())
        self.confirmedDay = startDay
        self.selectedDayRelay.accept(startDay)
    }

    // MARK: - External
    func resetToConfirmedDay() {
        selectedDayRelay.accept(confirmedDay)
    }
}
