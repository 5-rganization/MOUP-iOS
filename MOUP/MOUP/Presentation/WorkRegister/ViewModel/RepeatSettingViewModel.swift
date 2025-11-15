//
//  RepeatSettingViewModel.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol RepeatSettingViewModelInput {
    var dateSelected: PublishRelay<Date> { get }
    var didTapDay: PublishRelay<Int> { get }
    var didTapRegister: PublishRelay<Void> { get }
}

protocol RepeatSettingViewModelOutput {
    var isFormValid: Driver<Bool> { get }
    var didCompleteRepeatSetting: PublishRelay<(endDate: Date, days: [Int])> { get }
}

final class RepeatSettingViewModel:
    RepeatSettingViewModelInput,
    RepeatSettingViewModelOutput {

    // MARK: - Input
    let dateSelected = PublishRelay<Date>()
    let didTapDay = PublishRelay<Int>()
    let didTapRegister = PublishRelay<Void>()

    // MARK: - Output
    let isFormValid: Driver<Bool>
    let didCompleteRepeatSetting = PublishRelay<(endDate: Date, days: [Int])>()

    // MARK: - States
    let selectedDate = BehaviorRelay<Date?>(value: nil)
    let selectedDays = BehaviorRelay<Set<Int>>(value: [])
    
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init() {

        // 날짜 업데이트
        dateSelected
            .bind(to: selectedDate)
            .disposed(by: disposeBag)

        // 요일 토글
        didTapDay
            .withLatestFrom(selectedDays) { (index: $0, current: $1) }
            .map { info -> Set<Int> in
                var set = info.current
                if set.contains(info.index) {
                    set.remove(info.index)
                } else {
                    set.insert(info.index)
                }
                return set
            }
            .bind(to: selectedDays)
            .disposed(by: disposeBag)

        // 버튼 활성화
        self.isFormValid = Observable
            .combineLatest(
                selectedDate.map { $0 != nil },
                selectedDays.map { !$0.isEmpty }
            )
            .map { $0 && $1 }
            .asDriver(onErrorJustReturn: false)

        // 완료 전달
        didTapRegister
            .withLatestFrom(Observable.combineLatest(selectedDate, selectedDays))
            .compactMap { (date, days) -> (Date, [Int])? in
                guard let date else { return nil }
                return (date, Array(days).sorted())
            }
            .bind(to: didCompleteRepeatSetting)
            .disposed(by: disposeBag)
    }

    // MARK: - 초기값 주입
    func configureInitial(endDate: Date?, daysIndex: [Int]?) {
        if let endDate = endDate {
            selectedDate.accept(endDate)
        }
        if let daysIndex = daysIndex {
            selectedDays.accept(Set(daysIndex))
        }
    }
}
