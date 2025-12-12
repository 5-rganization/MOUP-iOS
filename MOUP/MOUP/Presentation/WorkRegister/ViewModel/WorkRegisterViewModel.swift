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

enum WorkRegisterMode {
    case create
    case edit(workId: Int)
}

// MARK: - Input / Output
protocol WorkRegisterViewModelInput {
    var didTapRegister: PublishRelay<Void> { get }
    var memoText: BehaviorRelay<String> { get }
    var viewWillDisappear: PublishRelay<Void> { get }
}

protocol WorkRegisterViewModelOutput {
    var isFormValidForWorker: Driver<Bool> { get }
    var isFormValidForOwner: Driver<Bool> { get }
    var selectedDate: BehaviorRelay<Date> { get }
    var didCompleteRegister: PublishRelay<Void> { get }
    var errorMessage: PublishRelay<(title: String, message: String)> { get }
}

final class WorkRegisterViewModel:
    WorkRegisterViewModelInput,
    WorkRegisterViewModelOutput {

    // MARK: - Sub ViewModels
    let userRole: UserRole
    
    let mode: WorkRegisterMode
    
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
    let viewWillDisappear = PublishRelay<Void>()
    let didTapRegister = PublishRelay<Void>()
    let memoText = BehaviorRelay<String>(value: "")
    let editPrefilledData = PublishRelay<WorkerWorkData>()
    
    // MARK: - Output (lazy 로 변경 → 초기화 순서 문제 해결)
    lazy var isFormValidForWorker: Driver<Bool> = {
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
    lazy var isFormValidForOwner: Driver<Bool> = {
        return Observable
            .combineLatest(
                // TODO: 근무자 선택 조건 추가
                selectedWorkplaceVM.confirmSelectedWorkplace.map { _ in true }.startWith(false),
                datePickerVM.confirmSelectedDate.map { _ in true }.startWith(false),
                clockInVM.confirmSelectedTime.map { _ in true }.startWith(false),
                clockOutVM.confirmSelectedTime.map { _ in true }.startWith(false)
            )
            .map { $0 && $1 && $2 && $3 }
            .asDriver(onErrorJustReturn: false)
    }()
    let selectedDate = BehaviorRelay<Date>(value: .now)
    
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private var createTask: Task<Void, Never>?

    let didCompleteRegister = PublishRelay<Void>()
    let errorMessage = PublishRelay<(title: String, message: String)>()

    // MARK: - Dependencies
    private let workUseCase: WorkUseCaseProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(
        mode: WorkRegisterMode,
        selectedWorkplaceVM: SelectedWorkplaceViewModel,
        datePickerVM: WorkDatePickerViewModel,
        clockInVM: WorkTimePickerViewModel,
        clockOutVM: WorkTimePickerViewModel,
        breakPickerVM: WorkBreakPickerViewModel,
        repeatSettingVM: RepeatSettingViewModel,
        workUseCase: WorkUseCaseProtocol,
        selectedDate: Date?,
        userRole: UserRole
    ) {
        self.mode = mode
        
        self.selectedWorkplaceVM = selectedWorkplaceVM
        self.datePickerVM = datePickerVM
        self.clockInVM = clockInVM
        self.clockOutVM = clockOutVM
        self.breakPickerVM = breakPickerVM
        self.repeatSettingVM = repeatSettingVM
        self.workUseCase = workUseCase
        self.userRole = userRole 
        self.selectedDate.accept(selectedDate ?? .now)
        
        bindRepeatSetting()
        bindRegisterAction()
        bindViewWillDisappear()
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

                let routineIDs = routines.map { $0.routineId }

                // 반복 종료일 문자열 변환
                let repeatEndDateString: String? = repeatInfo.map { info in
                    DateFormatter.dataSourceDateFormatter.string(from: info.endDate)
                }

                // 공통 필드 — updateDTO (수정 시 사용)
                let updateDTO = MyWorkUpdateRequestDTO(
                    routineIdList: routineIDs,
                    startTime: clockIn,
                    actualStartTime: nil,
                    endTime: clockOut,
                    actualEndTime: nil,
                    restTimeMinutes: breakMin,
                    memo: memo,
                    repeatDays: repeatInfo?.daysEN ?? [],
                    repeatEndDate: repeatEndDateString
                )

                // createDTO (등록 시 사용)
                let createDTO = MyWorkCreateRequestDTO(
                    routineIdList: routineIDs,
                    startTime: clockIn,
                    actualStartTime: nil,
                    endTime: clockOut,
                    actualEndTime: nil,
                    restTimeMinutes: breakMin,
                    memo: memo,
                    repeatDays: repeatInfo?.daysEN ?? [],
                    repeatEndDate: repeatEndDateString
                )

                self.createTask?.cancel()
                self.createTask = Task {
                    do {
                        switch self.mode {

                        // 신규 등록
                        case .create:
                            _ = try await self.workUseCase.createMyWork(
                                workplaceId: workplace.id,
                                requestDTO: createDTO
                            )

                        // 단일 근무 수정
                        case .edit(let workId):
                            try await self.workUseCase.updateMySingleWork(
                                workId: workId,
                                requestDTO: updateDTO
                            )
                        }

                        try Task.checkCancellation()

                        await MainActor.run {
                            self.didCompleteRegister.accept(())
                        }

                    } catch {
                        await MainActor.run {
                            self.errorMessage.accept((
                                title: "근무 저장 실패",
                                message: "근무 저장 중 오류가 발생했습니다. 다시 시도해주세요."
                            ))
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }


    
    func bindViewWillDisappear() {
        viewWillDisappear
            .subscribe(with: self) { owner, _ in
                owner.createTask = nil
            }.disposed(by: disposeBag)
    }
    
    
}
extension WorkRegisterViewModel {

    func loadEditData(workId: Int) {
        Task {
            do {
                // 조회 API 호출
                let detail = try await workUseCase.fetchWorkerWorkDetail(workId: workId)

                await MainActor.run {

                    // MARK: 1) 근무지 선택값 반영
                    let wp = detail.workplaceSummary
                    selectedWorkplaceVM.confirmSelectedWorkplace
                        .accept((id: wp.id, name: wp.name))

                    // MARK: 2) 날짜
                    if let date = DateFormatter.dataSourceDateFormatter.date(from: detail.workDate) {
                        selectedDate.accept(date)
                        datePickerVM.forceConfirmCurrentDate()
                    }

                    // MARK: 3) 출근/퇴근 시간
                    let start = detail.startTime
                    clockInVM.reconfigure(anchorDate: start, confirmedDate: start)
                    clockInVM.applyInitialConfirmedDate(start)

                    if let end = detail.endTime {
                        clockOutVM.reconfigure(anchorDate: end, confirmedDate: end)
                        clockOutVM.applyInitialConfirmedDate(end)
                    }
                    // MARK: 4) 휴게 시간
                    breakPickerVM.confirmSelectedBreak
                    breakPickerVM.setInitialBreak(detail.restTimeMinutes)

                    // MARK: 5) 루틴 목록
                    selectedRoutines.accept(detail.routineSummaryInfoList)

                    // MARK: 6) 메모
                    memoText.accept(detail.memo ?? "")

                    // MARK: 7) 반복 설정
                    if !detail.repeatDays.isEmpty,
                       let endRepeat = DateFormatter.dataSourceDateFormatter.date(from: detail.repeatEndDate ?? "") {

                        let daysIndex = detail.repeatDays.compactMap { dayEN in
                            ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
                                .firstIndex(of: dayEN)
                        }

                        repeatInfo.accept(
                            RepeatInfo(
                                endDate: endRepeat,
                                daysEN: detail.repeatDays,
                                daysIndex: daysIndex
                            )
                        )
                    }
                    self.editPrefilledData.accept(detail)
                }

            } catch {
                await MainActor.run {
                    self.errorMessage.accept((
                        title: "데이터 불러오기 실패",
                        message: "근무 정보를 불러오지 못했습니다. 다시 시도해주세요."
                    ))
                }
            }
        }
    }
}
