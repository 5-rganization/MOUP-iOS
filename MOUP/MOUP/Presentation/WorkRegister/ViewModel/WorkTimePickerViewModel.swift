//
//  WorkTimePickerViewModel.swift
//  MOUP
//
//  Created by 양원식 on 8/13/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol WorkTimePickerViewModelInput {
    var didTapConfirm: AnyObserver<Void> { get }
    var didTapCancel: AnyObserver<Void> { get }
    var selectedAMPM: AnyObserver<Int> { get }     // 0 = AM, 1 = PM
    var selectedHour: AnyObserver<Int> { get }     // 1...12
    var selectedMinute: AnyObserver<Int> { get }   // 0...59
    func resetToConfirmedTime()
}

protocol WorkTimePickerViewModelOutput {
    var currentAMPM: Driver<Int> { get }       // 0 or 1
    var currentHour: Driver<Int> { get }       // 1...12
    var currentMinute: Driver<Int> { get }     // 0...59
    var confirmSelectedTime: Observable<Date> { get } // anchor date에 시간만 적용된 Date
    var dismiss: Observable<Void> { get }
}

final class WorkTimePickerViewModel: WorkTimePickerViewModelInput, WorkTimePickerViewModelOutput {

    // MARK: - State
    private let calendar = Calendar(identifier: .gregorian)
    private var anchorDate: Date // ← let → var (reconfigure 위해)

    private let ampmRelay: BehaviorRelay<Int>
    private let hourRelay: BehaviorRelay<Int>
    private let minuteRelay: BehaviorRelay<Int>

    private let confirmedAMPMRelay: BehaviorRelay<Int>
    private let confirmedHourRelay: BehaviorRelay<Int>
    private let confirmedMinuteRelay: BehaviorRelay<Int>

    // MARK: - Inputs
    private let didTapConfirmSubject = PublishSubject<Void>()
    private let didTapCancelSubject = PublishSubject<Void>()
    private let selectedAMPMSubject = PublishSubject<Int>()
    private let selectedHourSubject = PublishSubject<Int>()
    private let selectedMinuteSubject = PublishSubject<Int>()

    var didTapConfirm: AnyObserver<Void> { didTapConfirmSubject.asObserver() }
    var didTapCancel: AnyObserver<Void> { didTapCancelSubject.asObserver() }
    var selectedAMPM: AnyObserver<Int> { selectedAMPMSubject.asObserver() }
    var selectedHour: AnyObserver<Int> { selectedHourSubject.asObserver() }
    var selectedMinute: AnyObserver<Int> { selectedMinuteSubject.asObserver() }
    

    func resetToConfirmedTime() {
        ampmRelay.accept(confirmedAMPMRelay.value)
        hourRelay.accept(confirmedHourRelay.value)
        minuteRelay.accept(confirmedMinuteRelay.value)
    }

    // MARK: - Outputs
    var currentAMPM: Driver<Int> { ampmRelay.asDriver() }
    var currentHour: Driver<Int> { hourRelay.asDriver() }
    var currentMinute: Driver<Int> { minuteRelay.asDriver() }

    lazy var confirmSelectedTime: Observable<Date> = { [unowned self] in
        let triple = Observable.combineLatest(
            self.ampmRelay.asObservable(),
            self.hourRelay.asObservable(),
            self.minuteRelay.asObservable()
        )

        return self.didTapConfirmSubject
            .withLatestFrom(triple)
            .map { (ampm, hour12, minute) -> Date in
                // 12시간 -> 24시간
                var hour24 = hour12 % 12 + (ampm == 1 ? 12 : 0)
                if hour24 == 24 { hour24 = 12 }

                var comp = self.calendar.dateComponents([.year,.month,.day], from: self.anchorDate)
                comp.hour = hour24
                comp.minute = minute
                comp.second = 0
                return self.calendar.date(from: comp) ?? self.anchorDate
            }
            .do(onNext: { date in
                let c = self.calendar.dateComponents([.hour,.minute], from: date)
                let h24 = c.hour ?? 0
                let m   = c.minute ?? 0
                let ampm = h24 >= 12 ? 1 : 0
                var h12 = h24 % 12
                if h12 == 0 { h12 = 12 }

                self.confirmedAMPMRelay.accept(ampm)
                self.confirmedHourRelay.accept(h12)
                self.confirmedMinuteRelay.accept(m)
            })
            .share()
    }()

    var dismiss: Observable<Void> { didTapCancelSubject.asObservable() }

    private let disposeBag = DisposeBag()

    // MARK: - Init
    /// - Parameters:
    ///   - initialDate: 초기 표시용(연월일 앵커 + 초기 시/분)
    ///   - confirmedDate: 이미 확정해둔 값이 있으면 seed로 사용
    init(initialDate: Date = Date(), confirmedDate: Date? = nil) {
        self.anchorDate = initialDate

        // seed는 confirmedDate ?? initialDate
        let seed = confirmedDate ?? initialDate
        let comp = Calendar.current.dateComponents([.hour,.minute], from: seed)
        let h24 = comp.hour ?? 0
        let m = comp.minute ?? 0
        let ampmInit = h24 >= 12 ? 1 : 0
        var h12 = h24 % 12; if h12 == 0 { h12 = 12 }

        ampmRelay = BehaviorRelay(value: ampmInit)
        hourRelay = BehaviorRelay(value: h12)
        minuteRelay = BehaviorRelay(value: m)

        confirmedAMPMRelay = BehaviorRelay(value: ampmInit)
        confirmedHourRelay = BehaviorRelay(value: h12)
        confirmedMinuteRelay = BehaviorRelay(value: m)

        // selections
        selectedAMPMSubject.bind(to: ampmRelay).disposed(by: disposeBag)
        selectedHourSubject.bind(to: hourRelay).disposed(by: disposeBag)
        selectedMinuteSubject.bind(to: minuteRelay).disposed(by: disposeBag)
    }

    // MARK: - Reconfigure (같은 VM 재사용 시 필수)
    func reconfigure(anchorDate: Date, confirmedDate: Date?) {
        self.anchorDate = anchorDate
        let seed = confirmedDate ?? anchorDate

        let comp = Calendar.current.dateComponents([.hour,.minute], from: seed)
        let h24 = comp.hour ?? 0
        let m = comp.minute ?? 0
        let ampm = h24 >= 12 ? 1 : 0
        var h12 = h24 % 12; if h12 == 0 { h12 = 12 }

        // 현재 선택 바퀴 갱신
        ampmRelay.accept(ampm)
        hourRelay.accept(h12)
        minuteRelay.accept(m)

        // 확정값도 seed로 동기화
        confirmedAMPMRelay.accept(ampm)
        confirmedHourRelay.accept(h12)
        confirmedMinuteRelay.accept(m)
        
        didTapConfirmSubject.onNext(())
    }
    
    /// 외부에서 초기 확정 값을 강제로 emit할 때 사용
    func applyInitialConfirmedDate(_ date: Date) {
        let comp = calendar.dateComponents([.hour, .minute], from: date)
        let h24 = comp.hour ?? 0
        let m = comp.minute ?? 0
        let ampm = h24 >= 12 ? 1 : 0
        var h12 = h24 % 12; if h12 == 0 { h12 = 12 }

        // UI 바퀴값 업데이트
        ampmRelay.accept(ampm)
        hourRelay.accept(h12)
        minuteRelay.accept(m)

        // 확정 값도 업데이트
        confirmedAMPMRelay.accept(ampm)
        confirmedHourRelay.accept(h12)
        confirmedMinuteRelay.accept(m)

        // confirmSelectedTime 이 emit 되도록 subject 트리거
        didTapConfirmSubject.onNext(())
    }

    
}
