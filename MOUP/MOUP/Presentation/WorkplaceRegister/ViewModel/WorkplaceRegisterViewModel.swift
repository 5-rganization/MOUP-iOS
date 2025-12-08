//
//  WorkplaceRegisterViewModel.swift
//  MOUP
//
//  Created by 양원식 on 8/4/25.
//
import Foundation
import RxSwift
import RxRelay
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
            .flatMapLatest { [weak self] requestDTO -> Observable<Int> in
                guard let self else { return Observable.empty() }

                return Observable.create { observer in
                    Task {
                        do {
                            switch self.mode {

                            case .create:
                                // 알바생 신규 생성
                                let result = try await self.workplaceUseCase.createWorkplace(request: requestDTO)
                                observer.onNext(result.workplaceId)

                            case .edit(let workplaceId):
                                print("[UPDATE] 수정 API 호출 worker mode - id=\(workplaceId)")

                                // Salary 업데이트 DTO 변환
                                let updateDTO = UpdateWorkplaceRequestDTO(
                                    workplaceName: requestDTO.workplaceName,
                                    categoryName: requestDTO.categoryName,
                                    address: requestDTO.address,
                                    latitude: requestDTO.latitude,
                                    longitude: requestDTO.longitude,
                                    workerBasedLabelColor: requestDTO.workerBasedLabelColor,
                                    salaryUpdateRequest: SalaryUpdateRequestDTO(
                                        salaryType: requestDTO.salaryCreateRequest.salaryType,
                                        salaryCalculation: requestDTO.salaryCreateRequest.salaryCalculation,
                                        hourlyRate: requestDTO.salaryCreateRequest.hourlyRate,
                                        salaryDate: requestDTO.salaryCreateRequest.salaryDate,
                                        hasNationalPension: requestDTO.salaryCreateRequest.hasNationalPension,
                                        hasHealthInsurance: requestDTO.salaryCreateRequest.hasHealthInsurance,
                                        hasEmploymentInsurance: requestDTO.salaryCreateRequest.hasEmploymentInsurance,
                                        hasIndustrialAccident: requestDTO.salaryCreateRequest.hasIndustrialAccident,
                                        hasIncomeTax: requestDTO.salaryCreateRequest.hasIncomeTax,
                                        hasHolidayAllowance: requestDTO.salaryCreateRequest.hasHolidayAllowance,
                                        hasNightAllowance: requestDTO.salaryCreateRequest.hasNightAllowance
                                    )
                                )

                                try await self.workplaceUseCase.updateWorkplace(
                                    workplaceId: workplaceId,
                                    request: updateDTO
                                )

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
        
        // MARK: 수정 모드일 경우 서버 데이터 로드 후 UI 반영
        if case let .edit(workplaceId) = mode {
            Task {
                do {
                    let detail = try await workplaceUseCase.fetchWorkplaceDetail(workplaceId: workplaceId)

                    workplaceVM.inputNameViewModel.confirmedNameRelay.accept(detail.workplaceName)
                    workplaceVM.selectCategoryViewModel.confirmedCategorySubject.accept(detail.categoryName)

                    if let color = detail.workerBasedLabelColor,
                       let mapped = LabelColor(serverStr: color)?.displayStr {
                        colorLabelVM.selectColorLabelViewModel.confirmedColorRelay.accept(mapped)
                    }

                    if let salary = detail.salaryDetailInfo {

                        // 급여 타입
                        if let display = SalaryType(serverValue: salary.salaryType)?.displayText {
                            payVM.selectPayTypeViewModel.confirmedPayTypeSubject.accept(display)
                        }

                        // 급여 계산 방식
                        if let display = SalaryCalculation(serverValue: salary.salaryCalculation)?.displayStr {
                            payVM.selectPayCalculationViewModel.confirmedPayCalculationSubject.accept(display)
                        }

                        // 시급/급여 금액
                        if let rate = salary.hourlyRate {
                            payVM.inputSalaryTypeViewModel.setInitialSalary(rate)
                        }

                        // 월급날
                        if let day = salary.salaryDate {
                            payVM.payDayPickerViewModel.setInitialDay(day)
                        }

                        workingConditionsVM.nationalPensionRelay.accept(salary.hasNationalPension ?? false)
                        workingConditionsVM.healthInsuranceRelay.accept(salary.hasHealthInsurance ?? false)
                        workingConditionsVM.employmentInsuranceRelay.accept(salary.hasEmploymentInsurance ?? false)
                        workingConditionsVM.industrialAccidentInsuranceRelay.accept(salary.hasIndustrialAccident ?? false)
                        workingConditionsVM.incomeTaxInsuranceRelay.accept(salary.hasIncomeTax ?? false)
                        workingConditionsVM.weeklyHolidayAllowanceInsuranceRelay.accept(salary.hasHolidayAllowance ?? false)
                        workingConditionsVM.nightShiftAllowanceInsuranceRelay.accept(salary.hasNightAllowance ?? false)
                    }

                } catch {
                    print("상세 조회 실패:", error)
                }
            }
        }


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

        // DTO 변환
        self.workplaceData = Observable
            .combineLatest(firstGroup, secondGroup)
            .map { first, second -> WorkplaceCreateRequestDTO in
                let (name, category, payType, payCalc, salary,
                     payday, pension, health) = first

                let (employment, industrial, tax, holiday, night, color) = second

                let mappedColor = LabelColor(displayStr: color)?.serverStr ?? LabelColor._default.serverStr
                let mappedPayCalc = SalaryCalculation(displayStr: payCalc)?.serverValue ?? payCalc
                let mappedPayType = SalaryType(displayText: payType)?.serverValue ?? payType

                return WorkplaceCreateRequestDTO(
                    workplaceName: name,
                    categoryName: category,
                    address: "기본 주소",    // 필요시 연결
                    latitude: 0.0,
                    longitude: 0.0,
                    workerBasedLabelColor: mappedColor,
                    salaryCreateRequest: SalaryCreateRequest(
                        salaryType: mappedPayType,
                        salaryCalculation: mappedPayCalc,
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
