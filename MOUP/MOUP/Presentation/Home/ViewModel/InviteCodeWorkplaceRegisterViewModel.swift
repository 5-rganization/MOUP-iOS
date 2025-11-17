//
//  InviteCodeWorkplaceRegisterViewModel.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol InviteCodeWorkplaceRegisterViewModelInput {
    var didTapRegisterButton: AnyObserver<Void> { get }
}

protocol InviteCodeWorkplaceRegisterViewModelOutput {
    var isFormValid: Driver<Bool> { get }
    var didCompleteRegister: Observable<Void> { get }
}

final class InviteCodeWorkplaceRegisterViewModel:
    InviteCodeWorkplaceRegisterViewModelInput,
    InviteCodeWorkplaceRegisterViewModelOutput {

    // MARK: - Exposed Container VMs
    let payVM: PayContainerViewModel
    let workingConditionsVM: WorkingConditionsContainerViewModel
    let colorLabelVM: ColorLabelContainerViewModel

    // MARK: - Input
    private let didTapRegisterSubject = PublishSubject<Void>()
    var didTapRegisterButton: AnyObserver<Void> { didTapRegisterSubject.asObserver() }

    // MARK: - Output
    let isFormValid: Driver<Bool>
    let didCompleteRegister: Observable<Void>

    // MARK: - Dependencies
    private let inviteCode: String
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(
        inviteCode: String,
        payVM: PayContainerViewModel,
        workingConditionsVM: WorkingConditionsContainerViewModel,
        colorLabelVM: ColorLabelContainerViewModel,
        workplaceUseCase: WorkplaceUseCaseProtocol
    ) {
        self.inviteCode = inviteCode
        self.payVM = payVM
        self.workingConditionsVM = workingConditionsVM
        self.colorLabelVM = colorLabelVM
        self.workplaceUseCase = workplaceUseCase

        // MARK: - Combine First Group
        let firstGroup = Observable.combineLatest(
            payVM.payTypeOutput.asObservable(),          // ex: "매월"
            payVM.payCalculationOutput.asObservable(),   // ex: "시급"
            payVM.salaryOutput.asObservable(),           // ex: "15000"
            payVM.payDayOutput.asObservable(),           // ex: "15일"
            workingConditionsVM.isNationalPensionChecked,
            workingConditionsVM.isHealthInsuranceChecked
        )

        // MARK: - Combine Second Group
        let secondGroup = Observable.combineLatest(
            workingConditionsVM.isEmploymentInsuranceChecked,
            workingConditionsVM.isIndustrialAccidentInsuranceChecked,
            workingConditionsVM.isIncomeTaxInsuranceChecked,
            workingConditionsVM.isWeeklyHolidayAllowanceInsuranceChecked,
            workingConditionsVM.isNightShiftAllowanceInsuranceChecked,
            colorLabelVM.selectedColorLabel.asObservable()   // ex: "초록색"
        )

        // MARK: - DTO Mapper
        let joinData = Observable
            .combineLatest(firstGroup, secondGroup)
            .map { first, second -> WorkplaceJoinRequestDTO in
                
                let (
                    payTypeText, payCalcText, salaryInput,
                    payDayText, pension, health
                ) = first

                let (
                    employment, industrial, tax,
                    holiday, night, colorText
                ) = second

                let mappedSalaryType =
                    SalaryType(displayText: payTypeText)?.serverValue ?? ""

                let mappedSalaryCalculation =
                    SalaryCalculation(displayStr: payCalcText)?.rawValue ?? ""

                let mappedColor =
                    WorkerLabelColor(displayText: colorText)?.serverValue ?? ""

                let numericSalary = Int(salaryInput) ?? 0

                let hourlyRate: Int?
                let fixedRate: Int?

                if mappedSalaryCalculation == "SALARY_CALCULATION_HOURLY" {
                    hourlyRate = numericSalary
                    fixedRate = nil
                } else {
                    hourlyRate = nil
                    fixedRate = numericSalary
                }

                let salaryDate = Int(payDayText.replacingOccurrences(of: "일", with: "")) ?? 1

                return WorkplaceJoinRequestDTO(
                    inviteCode: inviteCode,
                    workerBasedLabelColor: mappedColor,
                    salaryCreateRequest: SalaryJoinCreateRequest(
                        salaryType: mappedSalaryType,
                        salaryCalculation: mappedSalaryCalculation,
                        hourlyRate: hourlyRate,
                        fixedRate: fixedRate,
                        salaryDate: salaryDate,
                        salaryDay: "MONDAY",
                        hasNationalPension: pension,
                        hasHealthInsurance: health,
                        hasEmploymentInsurance: employment,
                        hasIndustrialAccident: industrial,
                        hasIncomeTax: tax,
                        hasHolidayAllowance: holiday,
                        hasNightAllowance: night
                    )
                )
            }
            .share(replay: 1)

        // MARK: - Validation
        self.isFormValid = joinData
            .map {
                let s = $0.salaryCreateRequest
                return !$0.workerBasedLabelColor.isEmpty &&
                !s.salaryType.isEmpty &&
                !s.salaryCalculation.isEmpty &&
                (s.hourlyRate ?? 0 > 0 || s.fixedRate ?? 0 > 0)
            }
            .asDriver(onErrorJustReturn: false)

        // MARK: - Register (Join Workplace)
        self.didCompleteRegister = didTapRegisterSubject
            .withLatestFrom(joinData)
            .flatMapLatest { request in
                Observable.create { observer in
                    Task {
                        do {
                            try await workplaceUseCase.joinWorkplace(request: request)
                            observer.onNext(())
                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }
                    }
                    return Disposables.create()
                }
            }
            .share()
    }
}
