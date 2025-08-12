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
    var workplaceData: Observable<WorkplaceData> { get }
    var didCompleteRegister: Observable<WorkplaceData> { get }
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
    let workplaceData: Observable<WorkplaceData>
    let didCompleteRegister: Observable<WorkplaceData>

    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(
        workplaceVM: WorkplaceContainerViewModel,
        payVM: PayContainerViewModel,
        workingConditionsVM: WorkingConditionsContainerViewModel,
        colorLabelVM: ColorLabelContainerViewModel
    ) {
        
        self.workplaceVM = workplaceVM
        self.payVM = payVM
        self.workingConditionsVM = workingConditionsVM
        self.colorLabelVM = colorLabelVM
        
        // combine 8개 이하로 나눠서 combineLatest
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

        // 조합해서 workplaceData 생성
        self.workplaceData = Observable
            .combineLatest(firstGroup, secondGroup)
            .map { first, second in
                let (
                    name, category, payType, payCalc, salary,
                    payday, pension, health
                ) = first

                let (
                    employment, industrial, tax, holiday, night, color
                ) = second

                return WorkplaceData(
                    id: "0", // TODO: - 없던 버전으로 바꾸기
                    name: name,
                    category: category,
                    payType: payType,
                    payCalculation: payCalc,
                    salary: salary,
                    payDay: payday,
                    nationalPension: pension,
                    healthInsurance: health,
                    employmentInsurance: employment,
                    industrialAccidentInsurance: industrial,
                    incomeTax: tax,
                    weeklyHolidayAllowance: holiday,
                    nightShiftAllowance: night,
                    colorLabel: color
                )
            }
            .share(replay: 1)

        // 유효성 검사
        self.isFormValid = workplaceData
            .map {
                !$0.name.isEmpty &&
                !$0.category.isEmpty &&
                !$0.payType.isEmpty &&
                !$0.payCalculation.isEmpty &&
                !$0.salary.isEmpty &&
                !$0.colorLabel.isEmpty
            }
            .asDriver(onErrorJustReturn: false)

        // 완료 버튼 탭 시 workplaceData 발행
        self.didCompleteRegister = didTapCompleteButtonSubject
            .withLatestFrom(workplaceData)
    }
}

