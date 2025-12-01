//
//  WorkplaceRegisterViewModel.swift
//  MOUP
//
//  Created by 양원식 on 8/4/25.
//
import Foundation
import RxSwift
import RxCocoa

enum WorkplaceRegisterMode {
    case create
    case edit(workplaceId: Int)
}

// MARK: - Input / Output
protocol WorkplaceRegisterViewModelInput {
    var didTapCompleteButton: AnyObserver<Void> { get }
}

protocol WorkplaceRegisterViewModelOutput {
    var isFormValid: Driver<Bool> { get }
    var didCompleteRegister: Observable<Int> { get }
}

final class WorkplaceRegisterViewModel: WorkplaceRegisterViewModelInput, WorkplaceRegisterViewModelOutput {

    // MARK: - Mode
    let mode: WorkplaceRegisterMode

    // MARK: - Child ViewModels
    let workplaceVM: WorkplaceContainerViewModel
    let payVM: PayContainerViewModel
    let workingConditionsVM: WorkingConditionsContainerViewModel
    let colorLabelVM: ColorLabelContainerViewModel

    // MARK: - Input
    private let didTapCompleteButtonSubject = PublishSubject<Void>()
    var didTapCompleteButton: AnyObserver<Void> { didTapCompleteButtonSubject.asObserver() }

    // MARK: - Output
    let isFormValid: Driver<Bool>

    lazy var didCompleteRegister: Observable<Int> = {
        didTapCompleteButtonSubject
            .withLatestFrom(workplaceData)
            .flatMapLatest { [weak self] request -> Observable<Int> in
                guard let self else { return Observable.empty() }

                return Observable<Int>.create { observer in
                    Task {
                        do {
                            switch self.mode {
                            case .create:
                                let result = try await self.workplaceUseCase.createWorkplace(request: request)
                                observer.onNext(result.workplaceId)

                            case .edit(let workplaceId):
                                // TODO: 수정 API 연동 예정
                                print("수정모드 — updateWorkplace API workplaceId=\(workplaceId)")
                                observer.onNext(workplaceId)
                            }

                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }
                    }
                    return Disposables.create()
                }
            }
            .share()
    }()

    // MARK: - Dependencies
    let workplaceUseCase: WorkplaceUseCaseProtocol
    private let disposeBag = DisposeBag()

    // 내부 observable (lazy 에서 사용)
    private let workplaceData: Observable<WorkplaceCreateRequestDTO>


    // MARK: - Init
    init(
        mode: WorkplaceRegisterMode,
        workplaceVM: WorkplaceContainerViewModel,
        payVM: PayContainerViewModel,
        workingConditionsVM: WorkingConditionsContainerViewModel,
        colorLabelVM: ColorLabelContainerViewModel,
        workplaceUseCase: WorkplaceUseCaseProtocol
    ) {
        self.mode = mode
        self.workplaceVM = workplaceVM
        self.payVM = payVM
        self.workingConditionsVM = workingConditionsVM
        self.colorLabelVM = colorLabelVM
        self.workplaceUseCase = workplaceUseCase

        // MARK: - Combine Inputs
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

        // 내부 observable 저장
        self.workplaceData = Observable
            .combineLatest(firstGroup, secondGroup)
            .map { first, second -> WorkplaceCreateRequestDTO in
                let (name, category, payType, payCalc, salary,
                     payday, pension, health) = first

                let (employment, industrial, tax, holiday, night, color) = second

                let mappedColor = LabelColor(displayStr: color)?.serverStr ?? LabelColor._default.serverStr
                let mappedPayCalculation = SalaryCalculation(displayStr: payCalc)?.serverValue ?? payCalc
                let mappedPayType = SalaryType(displayText: payType)?.serverValue ?? payType

                return WorkplaceCreateRequestDTO(
                    workplaceName: name,
                    categoryName: category,
                    address: "기본값", // TODO: 실제 좌표 연동
                    latitude: 0.0,
                    longitude: 0.0,
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
    }
}
