//
//  WorkplaceRegisterViewModel.swift
//  MOUP
//
//  Created by 양원식 on 8/4/25.
//
import Foundation
import RxSwift
import RxCocoa

protocol WorkplaceRegisterViewModelInput {
    var didTapCompleteButton: AnyObserver<Void> { get }
}

protocol WorkplaceRegisterViewModelOutput {
    var isFormValid: Driver<Bool> { get }
    var didCompleteRegister: Observable<Int> { get }
}

final class WorkplaceRegisterViewModel: WorkplaceRegisterViewModelInput, WorkplaceRegisterViewModelOutput {
    
    // MARK: - Exposed Container ViewModels
    let workplaceVM: WorkplaceContainerViewModel
    let payVM: PayContainerViewModel
    let workingConditionsVM: WorkingConditionsContainerViewModel
    let colorLabelVM: ColorLabelContainerViewModel

    // MARK: - Input
    private let didTapCompleteButtonSubject = PublishSubject<Void>()
    var didTapCompleteButton: AnyObserver<Void> { didTapCompleteButtonSubject.asObserver() }

    // MARK: - Output
    let isFormValid: Driver<Bool>
    let didCompleteRegister: Observable<Int>

    // MARK: - Dependencies
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(
        workplaceVM: WorkplaceContainerViewModel,
        payVM: PayContainerViewModel,
        workingConditionsVM: WorkingConditionsContainerViewModel,
        colorLabelVM: ColorLabelContainerViewModel,
        workplaceUseCase: WorkplaceUseCaseProtocol
    ) {
        self.workplaceVM = workplaceVM
        self.payVM = payVM
        self.workingConditionsVM = workingConditionsVM
        self.colorLabelVM = colorLabelVM
        self.workplaceUseCase = workplaceUseCase
        
        let firstGroup = Observable.combineLatest(
            workplaceVM.nameTextOutput.asObservable(),
            workplaceVM.categoryTextOutput.asObservable(),
            payVM.payTypeOutput.asObservable(),
            payVM.payCalculationOutput.asObservable(),
            payVM.salaryOutput.asObservable(),
            payVM.payDayOutput.asObservable(),
            workingConditionsVM.isNationalPensionChecked,
            workingConditionsVM.isHealthInsuranceChecked
        )

        let secondGroup = Observable.combineLatest(
            workingConditionsVM.isEmploymentInsuranceChecked,
            workingConditionsVM.isIndustrialAccidentInsuranceChecked,
            workingConditionsVM.isIncomeTaxInsuranceChecked,
            workingConditionsVM.isWeeklyHolidayAllowanceInsuranceChecked,
            workingConditionsVM.isNightShiftAllowanceInsuranceChecked,
            colorLabelVM.selectedColorLabel.asObservable()
        )

        // MARK: - DTO 조합
        let workplaceData = Observable
            .combineLatest(firstGroup, secondGroup)
            .map { first, second -> WorkplaceCreateRequestDTO in
                let (
                    name, category, payType, payCalc, salary,
                    payday, pension, health
                ) = first

                let (
                    employment, industrial, tax, holiday, night, color
                ) = second

                // ENUM 매핑 처리
                let mappedColor = LabelColor(displayStr: color)?.serverStr ?? LabelColor._default.serverStr
                let mappedPayCalculation = SalaryCalculation(displayStr: payCalc)?.serverValue ?? payCalc
                let mappedPayType = SalaryType(displayText: payType)?.serverValue ?? payType

                return WorkplaceCreateRequestDTO(
                    workplaceName: name,
                    categoryName: category,
                    address: "기본값", // TODO: 실제 위치 값 연결
                    latitude: 0.0, // TODO: 실제 위치 값 연결
                    longitude: 0.0, // TODO: 실제 위치 값 연결
                    workerBasedLabelColor: mappedColor,
                    salaryCreateRequest: SalaryCreateRequest(
                        salaryType: mappedPayType,
                        salaryCalculation: mappedPayCalculation,
                        hourlyRate: Int(salary) ?? 0,
                        salaryDate: Int(payday.replacingOccurrences(of: "일", with: "")) ?? 0,
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
        self.isFormValid = workplaceData
            .map {
                !$0.workplaceName.isEmpty &&
                !$0.categoryName.isEmpty &&
                !$0.salaryCreateRequest.salaryType.isEmpty &&
                !$0.salaryCreateRequest.salaryCalculation.isEmpty &&
                $0.salaryCreateRequest.hourlyRate > 0 &&
                !$0.workerBasedLabelColor.isEmpty
            }
            .asDriver(onErrorJustReturn: false)

        // MARK: - Register Action
        self.didCompleteRegister = didTapCompleteButtonSubject
            .withLatestFrom(workplaceData)
            .flatMapLatest { request in
                Observable.create { observer in
                    Task {
                        do {
                            let result = try await workplaceUseCase.createWorkplace(request: request)
                            observer.onNext(result.workplaceId)
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
