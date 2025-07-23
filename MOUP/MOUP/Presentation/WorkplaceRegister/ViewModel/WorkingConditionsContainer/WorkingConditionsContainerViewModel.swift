//
//  WorkingConditionsContainerViewModel.swift
//  MOUP
//
//  Created by 양원식 on 7/23/25.
//

import RxSwift
import RxCocoa

protocol WorkingConditionsContainerViewModelInput {
    var toggleFourMajorInsurance: AnyObserver<Void> { get }
    var toggleNationalPension: AnyObserver<Void> { get }
    var toggleHealthInsurance: AnyObserver<Void> { get }
    var toggleEmploymentInsurance: AnyObserver<Void> { get }
    var toggleIndustrialAccidentInsurance: AnyObserver<Void> { get }
    var toggleIncomeTaxInsurance: AnyObserver<Void> { get }
    var toggleWeeklyHolidayAllowanceInsurance: AnyObserver<Void> { get }
    var toggleNightShiftAllowanceInsurance: AnyObserver<Void> { get }
}

protocol WorkingConditionsContainerViewModelOutput {
    var isFourMajorInsuranceChecked: Observable<Bool> { get }
    var isNationalPensionChecked: Observable<Bool> { get }
    var isHealthInsuranceChecked: Observable<Bool> { get }
    var isEmploymentInsuranceChecked: Observable<Bool> { get }
    var isIndustrialAccidentInsuranceChecked: Observable<Bool> { get }
    var isIncomeTaxInsuranceChecked: Observable<Bool> { get }
    var isWeeklyHolidayAllowanceInsuranceChecked: Observable<Bool> { get }
    var isNightShiftAllowanceInsuranceChecked: Observable<Bool> { get }
}

final class WorkingConditionsContainerViewModel: WorkingConditionsContainerViewModelInput, WorkingConditionsContainerViewModelOutput {

    // MARK: - Inputs
    private let toggleFourMajorInsuranceSubject = PublishSubject<Void>()
    private let toggleNationalPensionSubject = PublishSubject<Void>()
    private let toggleHealthInsuranceSubject = PublishSubject<Void>()
    private let toggleEmploymentInsuranceSubject = PublishSubject<Void>()
    private let toggleIndustrialAccidentInsuranceSubject = PublishSubject<Void>()
    private let toggleIncomeTaxInsuranceSubject = PublishSubject<Void>()
    private let toggleWeeklyHolidayAllowanceInsuranceSubject = PublishSubject<Void>()
    private let toggleNightShiftAllowanceInsuranceSubject = PublishSubject<Void>()

    var toggleFourMajorInsurance: AnyObserver<Void> { toggleFourMajorInsuranceSubject.asObserver() }
    var toggleNationalPension: AnyObserver<Void> { toggleNationalPensionSubject.asObserver() }
    var toggleHealthInsurance: AnyObserver<Void> { toggleHealthInsuranceSubject.asObserver() }
    var toggleEmploymentInsurance: AnyObserver<Void> { toggleEmploymentInsuranceSubject.asObserver() }
    var toggleIndustrialAccidentInsurance: AnyObserver<Void> { toggleIndustrialAccidentInsuranceSubject.asObserver() }
    var toggleIncomeTaxInsurance: AnyObserver<Void> { toggleIncomeTaxInsuranceSubject.asObserver() }
    var toggleWeeklyHolidayAllowanceInsurance: AnyObserver<Void> { toggleWeeklyHolidayAllowanceInsuranceSubject.asObserver() }
    var toggleNightShiftAllowanceInsurance: AnyObserver<Void> { toggleNightShiftAllowanceInsuranceSubject.asObserver() }

    // MARK: - Outputs
    let isFourMajorInsuranceChecked: Observable<Bool>
    let isNationalPensionChecked: Observable<Bool>
    let isHealthInsuranceChecked: Observable<Bool>
    let isEmploymentInsuranceChecked: Observable<Bool>
    let isIndustrialAccidentInsuranceChecked: Observable<Bool>
    let isIncomeTaxInsuranceChecked: Observable<Bool>
    let isWeeklyHolidayAllowanceInsuranceChecked: Observable<Bool>
    let isNightShiftAllowanceInsuranceChecked: Observable<Bool>

    private let nationalPensionRelay = BehaviorRelay<Bool>(value: false)
    private let healthInsuranceRelay = BehaviorRelay<Bool>(value: false)
    private let employmentInsuranceRelay = BehaviorRelay<Bool>(value: false)
    private let industrialAccidentInsuranceRelay = BehaviorRelay<Bool>(value: false)
    private let incomeTaxInsuranceRelay = BehaviorRelay<Bool>(value: false)
    private let weeklyHolidayAllowanceInsuranceRelay = BehaviorRelay<Bool>(value: false)
    private let nightShiftAllowanceInsuranceRelay = BehaviorRelay<Bool>(value: false)

    private let disposeBag = DisposeBag()

    // MARK: - Init
    init() {
        isNationalPensionChecked = nationalPensionRelay.asObservable()
        isHealthInsuranceChecked = healthInsuranceRelay.asObservable()
        isEmploymentInsuranceChecked = employmentInsuranceRelay.asObservable()
        isIndustrialAccidentInsuranceChecked = industrialAccidentInsuranceRelay.asObservable()
        isIncomeTaxInsuranceChecked = incomeTaxInsuranceRelay.asObservable()
        isWeeklyHolidayAllowanceInsuranceChecked = weeklyHolidayAllowanceInsuranceRelay.asObservable()
        isNightShiftAllowanceInsuranceChecked = nightShiftAllowanceInsuranceRelay.asObservable()


        // 4대 보험 전체 체크 상태: 모든 하위 항목이 true일 때만 true
        isFourMajorInsuranceChecked = Observable
            .combineLatest(
                nationalPensionRelay,
                healthInsuranceRelay,
                employmentInsuranceRelay,
                industrialAccidentInsuranceRelay
            )
            .map { $0 && $1 && $2 && $3 }
            .distinctUntilChanged()

        bindInputs()
    }

    private func bindInputs() {
        toggleFourMajorInsuranceSubject
            .withLatestFrom(isFourMajorInsuranceChecked)
            .subscribe(onNext: { [weak self] isChecked in
                let newValue = !isChecked
                self?.nationalPensionRelay.accept(newValue)
                self?.healthInsuranceRelay.accept(newValue)
                self?.employmentInsuranceRelay.accept(newValue)
                self?.industrialAccidentInsuranceRelay.accept(newValue)
            })
            .disposed(by: disposeBag)

        toggleNationalPensionSubject
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.nationalPensionRelay.accept(!self.nationalPensionRelay.value)
            })
            .disposed(by: disposeBag)

        toggleHealthInsuranceSubject
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.healthInsuranceRelay.accept(!self.healthInsuranceRelay.value)
            })
            .disposed(by: disposeBag)

        toggleEmploymentInsuranceSubject
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.employmentInsuranceRelay.accept(!self.employmentInsuranceRelay.value)
            })
            .disposed(by: disposeBag)

        toggleIndustrialAccidentInsuranceSubject
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.industrialAccidentInsuranceRelay.accept(!self.industrialAccidentInsuranceRelay.value)
            })
            .disposed(by: disposeBag)
        
        toggleIncomeTaxInsuranceSubject
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.incomeTaxInsuranceRelay.accept(!self.incomeTaxInsuranceRelay.value)
            })
            .disposed(by: disposeBag)

        toggleWeeklyHolidayAllowanceInsuranceSubject
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.weeklyHolidayAllowanceInsuranceRelay.accept(!self.weeklyHolidayAllowanceInsuranceRelay.value)
            })
            .disposed(by: disposeBag)

        toggleNightShiftAllowanceInsuranceSubject
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.nightShiftAllowanceInsuranceRelay.accept(!self.nightShiftAllowanceInsuranceRelay.value)
            })
            .disposed(by: disposeBag)

    }
}
