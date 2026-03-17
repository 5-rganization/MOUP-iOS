//
//  OLDWorkDatePickerViewModel.swift
//  MOUP
//
//  Created by 양원식 on 8/12/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol OLDWorkDatePickerViewModelInput {
    var didTapConfirm: AnyObserver<Void> { get }
    var didTapCancel: AnyObserver<Void> { get }
    var selectedYear: AnyObserver<Int> { get }
    var selectedMonth: AnyObserver<Int> { get }
    var selectedDay: AnyObserver<Int> { get }
    func resetToConfirmedDate()
}

protocol OLDWorkDatePickerViewModelOutput {
    var currentYear: Driver<Int> { get }
    var currentMonth: Driver<Int> { get }
    var currentDay: Driver<Int> { get }
    var confirmSelectedDate: Observable<Date> { get }
    var dismiss: Observable<Void> { get }
}

final class OLDWorkDatePickerViewModel: OLDWorkDatePickerViewModelInput, OLDWorkDatePickerViewModelOutput {
    
    // MARK: - State
    private let calendar = Calendar(identifier: .gregorian)
    
    private let yearRelay: BehaviorRelay<Int>
    private let monthRelay: BehaviorRelay<Int>
    private let dayRelay: BehaviorRelay<Int>
    
    private let confirmedYearRelay: BehaviorRelay<Int>
    private let confirmedMonthRelay: BehaviorRelay<Int>
    private let confirmedDayRelay: BehaviorRelay<Int>
    
    // MARK: - Inputs
    private let didTapConfirmSubject = PublishSubject<Void>()
    private let didTapCancelSubject = PublishSubject<Void>()
    private let selectedYearSubject = PublishSubject<Int>()
    private let selectedMonthSubject = PublishSubject<Int>()
    private let selectedDaySubject = PublishSubject<Int>()
    
    var didTapConfirm: AnyObserver<Void> { didTapConfirmSubject.asObserver() }
    var didTapCancel: AnyObserver<Void> { didTapCancelSubject.asObserver() }
    var selectedYear: AnyObserver<Int> { selectedYearSubject.asObserver() }
    var selectedMonth: AnyObserver<Int> { selectedMonthSubject.asObserver() }
    var selectedDay: AnyObserver<Int> { selectedDaySubject.asObserver() }
    
    func resetToConfirmedDate() {
        yearRelay.accept(confirmedYearRelay.value)
        monthRelay.accept(confirmedMonthRelay.value)
        dayRelay.accept(confirmedDayRelay.value)
    }
    
    // MARK: - Outputs
    var currentYear: Driver<Int> { yearRelay.asDriver() }
    var currentMonth: Driver<Int> { monthRelay.asDriver() }
    var currentDay: Driver<Int> { dayRelay.asDriver() }
    
    lazy var confirmSelectedDate: Observable<Date> = { [unowned self] in
        let ymd = Observable.combineLatest(
            self.yearRelay.asObservable(),
            self.monthRelay.asObservable(),
            self.dayRelay.asObservable()
        )

        return self.didTapConfirmSubject
            .withLatestFrom(ymd)
            .map { (yr, mo, da) -> Date in
                var comp = DateComponents()
                comp.year = yr; comp.month = mo; comp.day = da
                return self.calendar.date(from: comp) ?? Date()
            }
            .do(onNext: { date in
                let c = self.calendar.dateComponents([.year,.month,.day], from: date)
                self.confirmedYearRelay.accept(c.year  ?? self.yearRelay.value)
                self.confirmedMonthRelay.accept(c.month ?? self.monthRelay.value)
                self.confirmedDayRelay.accept(c.day   ?? self.dayRelay.value)
            })
            .share() // 선택: 중복 구독 시 부작용 방지
    }()
    var dismiss: Observable<Void> { didTapCancelSubject.asObservable() }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(initialDate: Date = Date(), confirmedDate: Date? = nil) {
        
        let c = Calendar.current.dateComponents([.year,.month,.day], from: initialDate)
        let y = c.year  ?? 2025
        let m = c.month ?? 1
        let d = c.day   ?? 1
        
        yearRelay  = BehaviorRelay(value: y)
        monthRelay = BehaviorRelay(value: m)
        dayRelay   = BehaviorRelay(value: d)
        
        let conf = Calendar.current.dateComponents([.year,.month,.day], from: confirmedDate ?? initialDate)
        confirmedYearRelay  = BehaviorRelay(value: conf.year  ?? y)
        confirmedMonthRelay = BehaviorRelay(value: conf.month ?? m)
        confirmedDayRelay   = BehaviorRelay(value: conf.day   ?? d)
        
        // selections
        selectedYearSubject.bind(to: yearRelay).disposed(by: disposeBag)
        selectedMonthSubject.bind(to: monthRelay).disposed(by: disposeBag)
        selectedDaySubject.bind(to: dayRelay).disposed(by: disposeBag)
    }
    
    func forceConfirmCurrentDate() {
        var comp = DateComponents()
        comp.year = yearRelay.value
        comp.month = monthRelay.value
        comp.day = dayRelay.value

        let date = calendar.date(from: comp) ?? Date()

        // confirmed 값 갱신
        confirmedYearRelay.accept(yearRelay.value)
        confirmedMonthRelay.accept(monthRelay.value)
        confirmedDayRelay.accept(dayRelay.value)

        // 실제 confirm 이벤트 발생
        didTapConfirmSubject.onNext(())
    }

}
