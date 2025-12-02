//
//  WorkRegisterViewModel.swift
//  MOUP
//
//  Created by 양원식 on 11/11/25.
//

import OSLog

import RxSwift
import RxRelay
import RxCocoa

// MARK: - Repeat Info Model
struct RepeatInfo {
    let endDate: Date
    let daysEN: [String]      // ex: ["MONDAY", "FRIDAY"]
    let daysIndex: [Int]      // ex: [1, 5]   ← UI 표시용
}

// MARK: - Input / Output
protocol WorkRegisterViewModelInput {
    var didTapRegister: PublishRelay<Void> { get }
    var memoText: BehaviorRelay<String> { get }
}

protocol WorkRegisterViewModelOutput {
    var isFormValid: Driver<Bool> { get }
    var didCompleteRegister: PublishRelay<Void> { get }
    var errorMessage: PublishRelay<(title: String, message: String)> { get }
}

final class WorkRegisterViewModel:
    WorkRegisterViewModelInput,
    WorkRegisterViewModelOutput {

    // MARK: - Sub ViewModels
    let selectedWorkplaceVM: SelectedWorkplaceViewModel
    let datePickerVM: WorkDatePickerViewModel
    let clockInVM: WorkTimePickerViewModel
    let clockOutVM: WorkTimePickerViewModel
    let breakPickerVM: WorkBreakPickerViewModel
    let repeatSettingVM: RepeatSettingViewModel

    // MARK: - Repeat Info (Optional)
    let repeatInfo = BehaviorRelay<RepeatInfo?>(value: nil)
    
    // MARK: - Selected Routine IDs
    let selectedRoutines = BehaviorRelay<[RoutineSummary]>(value: [])

    // MARK: - Input
    let didTapRegister = PublishRelay<Void>()
    let memoText = BehaviorRelay<String>(value: "")

    // MARK: - Output (lazy 로 변경 → 초기화 순서 문제 해결)
    lazy var isFormValid: Driver<Bool> = {
        return Observable
            .combineLatest(
                selectedWorkplaceVM.confirmSelectedWorkplace.map { _ in true }.startWith(false),
                datePickerVM.confirmSelectedDate.map { _ in true }.startWith(false),
                clockInVM.confirmSelectedTime.map { _ in true }.startWith(false),
                clockOutVM.confirmSelectedTime.map { _ in true }.startWith(false)
            )
            .map { $0 && $1 && $2 && $3 }
            .asDriver(onErrorJustReturn: false)
    }()
    
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private var createTask: Task<Void, Never>?

    let didCompleteRegister = PublishRelay<Void>()
    let errorMessage = PublishRelay<(title: String, message: String)>()

    // MARK: - Dependencies
    private let workUseCase: WorkUseCaseProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(
        selectedWorkplaceVM: SelectedWorkplaceViewModel,
        datePickerVM: WorkDatePickerViewModel,
        clockInVM: WorkTimePickerViewModel,
        clockOutVM: WorkTimePickerViewModel,
        breakPickerVM: WorkBreakPickerViewModel,
        repeatSettingVM: RepeatSettingViewModel,
        workUseCase: WorkUseCaseProtocol
    ) {
        self.selectedWorkplaceVM = selectedWorkplaceVM
        self.datePickerVM = datePickerVM
        self.clockInVM = clockInVM
        self.clockOutVM = clockOutVM
        self.breakPickerVM = breakPickerVM
        self.repeatSettingVM = repeatSettingVM
        self.workUseCase = workUseCase

        bindRepeatSetting()
        bindRegisterAction()
    }
}

// MARK: - Bindings
private extension WorkRegisterViewModel {

    /// 반복 설정 값 바인딩 (RepeatSettingVC → RegisterViewModel)
    func bindRepeatSetting() {
        // RepeatSetting 결과 받아서 repeatInfo 저장
        repeatSettingVM.didCompleteRepeatSetting
            .map { endDate, daysIndex -> RepeatInfo in
                let weekEN = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY",
                              "THURSDAY", "FRIDAY", "SATURDAY"]

                let daysEN = daysIndex.map { weekEN[$0] }

                return RepeatInfo(endDate: endDate, daysEN: daysEN, daysIndex: daysIndex)
            }
            .bind(to: repeatInfo)
            .disposed(by: disposeBag)

    }

    /// 등록 버튼 처리
    func bindRegisterAction() {
        didTapRegister
            .withLatestFrom(
                Observable.combineLatest(
                    selectedWorkplaceVM.confirmSelectedWorkplace,
                    datePickerVM.confirmSelectedDate,
                    clockInVM.confirmSelectedTime,
                    clockOutVM.confirmSelectedTime,
                    breakPickerVM.confirmSelectedBreak.startWith(0),
                    memoText.asObservable(),
                    repeatInfo.asObservable(),
                    selectedRoutines.asObservable()
                )
            )
            .subscribe(onNext: { [weak self]
                (workplace, date, clockIn, clockOut, breakMin, memo, repeatInfo, routines) in

                guard let self else { return }

                let dateStr = DateFormatter.dataSourceDateFormatter.string(from: date)
                let clockInStr = DateFormatter.ko12hTimeFormatter.string(from: clockIn)
                let clockOutStr = DateFormatter.ko12hTimeFormatter.string(from: clockOut)
                
                let routineIDs = routines.map { $0.routineId }

                print("--------------------------------------------------")
                print("근무 등록 요청")
                print("근무지: \(workplace.id) - \(workplace.name)")
                print("근무 날짜: \(dateStr)")
                print("출근 시간: \(clockInStr)")
                print("퇴근 시간: \(clockOutStr)")
                print("휴게 시간: \(breakMin)분")
                print("메모: \(memo)")

                if let r = repeatInfo {
                    print("반복 종료 날짜: \(r.endDate)")
                    print("반복 요일(EN): \(r.daysEN)")
                } else {
                    print("반복 없음")
                }
                print("선택된 루틴 IDs: \(routineIDs)")
                print("--------------------------------------------------")
                
                
                let requestDTO: MyWorkCreateRequestDTO
                if let repeatEndDate = repeatInfo?.endDate {
                    let repeatEndDateForDTO = DateFormatter.dataSourceDateFormatter.string(from: repeatEndDate)
                    requestDTO = MyWorkCreateRequestDTO(routineIdList: routineIDs, startTime: clockIn, actualStartTime: nil, endTime: clockOut, actualEndTime: nil, restTimeMinutes: breakMin, memo: memo, repeatDays: repeatInfo?.daysEN ?? [], repeatEndDate: repeatEndDateForDTO)
                } else {
                    requestDTO = MyWorkCreateRequestDTO(routineIdList: routineIDs, startTime: clockIn, actualStartTime: nil, endTime: clockOut, actualEndTime: nil, restTimeMinutes: breakMin, memo: memo, repeatDays: repeatInfo?.daysEN ?? [], repeatEndDate: nil)
                }
                
                createTask = Task {
                    do {
                        let createdWorkIdList = try await self.workUseCase.createMyWork(workplaceId: workplace.id, requestDTO: requestDTO)
                        try Task.checkCancellation()
                        
                        self.logger.debug("생성된 근무 ID 배열: \(createdWorkIdList)")
                    } catch is CancellationError {
                        self.logger.info("근무 생성 Task가 취소되었습니다.")
                    } catch let error as LocalizedError {
                        await MainActor.run {
                            self.errorMessage.accept((title: "근무 등록 실패", message: error.errorDescription ?? "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                        }
                    } catch {
                        await MainActor.run {
                            self.errorMessage.accept((title: "근무 등록 실패", message: "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                        }
                    }
                }
                
                
                self.didCompleteRegister.accept(())
            })
            .disposed(by: disposeBag)
    }
}
