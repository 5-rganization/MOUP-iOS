//
//  OLDWorkRegisterViewModel.swift
//  MOUP
//
//  Created by 양원식 on 11/11/25.
//

import OSLog

import RxSwift
import RxRelay
import RxCocoa

// MARK: - Repeat Info Model
struct OLDRepeatInfo {
    let endDate: Date
    let daysEN: [String]      // ex: ["MONDAY", "FRIDAY"]
    let daysIndex: [Int]      // ex: [1, 5]   ← UI 표시용
}

enum OLDWorkRegisterMode {
    case create
    case edit(workId: Int)
}

// MARK: - Input / Output
protocol OLDWorkRegisterViewModelInput {
    var didTapRegister: PublishRelay<Void> { get }
    var memoText: BehaviorRelay<String> { get }
    var viewWillDisappear: PublishRelay<Void> { get }
}

protocol OLDWorkRegisterViewModelOutput {
    var isFormValidForWorker: Driver<Bool> { get }
    var isFormValidForOwner: Driver<Bool> { get }
    var selectedDate: BehaviorRelay<Date> { get }
    var didCompleteRegister: PublishRelay<Void> { get }
    var errorMessage: PublishRelay<(title: String, message: String)> { get }
}

final class OLDWorkRegisterViewModel:
    OLDWorkRegisterViewModelInput,
    OLDWorkRegisterViewModelOutput {

    // MARK: - Sub ViewModels
    let userRole: UserRole
    
    let mode: OLDWorkRegisterMode
    
    let selectedWorkplaceVM: OLDSelectedWorkplaceViewModel
    let datePickerVM: OLDWorkDatePickerViewModel
    let clockInVM: OLDWorkTimePickerViewModel
    let clockOutVM: OLDWorkTimePickerViewModel
    let breakPickerVM: OLDWorkBreakPickerViewModel
    let repeatSettingVM: OLDRepeatSettingViewModel
    
    // MARK: - Repeat Info (Optional)
    let repeatInfo = BehaviorRelay<OLDRepeatInfo?>(value: nil)
    
    // MARK: - Selected Routine IDs
    let selectedRoutines = BehaviorRelay<[RoutineSummary]>(value: [])

    // MARK: - Input
    let viewWillDisappear = PublishRelay<Void>()
    let didTapRegister = PublishRelay<Void>()
    let memoText = BehaviorRelay<String>(value: "")
    let editPrefilledData = PublishRelay<WorkerWorkData>()
    // 사장님 전용 선택된 근무자 ID 목록
    let selectedWorkerIds = BehaviorRelay<[Int]>(value: [])
    
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
        mode: OLDWorkRegisterMode,
        selectedWorkplaceVM: OLDSelectedWorkplaceViewModel,
        datePickerVM: OLDWorkDatePickerViewModel,
        clockInVM: OLDWorkTimePickerViewModel,
        clockOutVM: OLDWorkTimePickerViewModel,
        breakPickerVM: OLDWorkBreakPickerViewModel,
        repeatSettingVM: OLDRepeatSettingViewModel,
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
private extension OLDWorkRegisterViewModel {

    /// 반복 설정 값 바인딩 (RepeatSettingVC → RegisterViewModel)
    func bindRepeatSetting() {
        // RepeatSetting 결과 받아서 repeatInfo 저장
        repeatSettingVM.didCompleteRepeatSetting
            .map { endDate, daysIndex -> OLDRepeatInfo in
                let weekEN = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY",
                              "THURSDAY", "FRIDAY", "SATURDAY"]

                let daysEN = daysIndex.map { weekEN[$0] }

                return OLDRepeatInfo(endDate: endDate, daysEN: daysEN, daysIndex: daysIndex)
            }
            .bind(to: repeatInfo)
            .disposed(by: disposeBag)

    }

    /// 등록 버튼 처리
    func bindRegisterAction() {

        let baseCombined = Observable.combineLatest(
            selectedWorkplaceVM.confirmSelectedWorkplace,   // 1
            datePickerVM.confirmSelectedDate,               // 2
            clockInVM.confirmSelectedTime,                  // 3
            clockOutVM.confirmSelectedTime,                 // 4
            breakPickerVM.confirmSelectedBreak.startWith(0),// 5
            memoText.asObservable(),                        // 6
            repeatInfo.asObservable(),                      // 7
            selectedRoutines.asObservable()                 // 8
        )

        didTapRegister
            .withLatestFrom(
                Observable.combineLatest(
                    baseCombined,
                    selectedWorkerIds.asObservable()
                )
            )
            .subscribe(onNext: { [weak self] base, workerIds in
                guard let self else { return }

                // base 튜플 풀기
                let (
                    workplace,
                    date,
                    clockIn,
                    clockOut,
                    breakMin,
                    memo,
                    repeatInfo,
                    routines
                ) = base

                let routineIDs = routines.map { $0.routineId }

                let repeatEndDateString: String? = repeatInfo.map {
                    DateFormatter.dataSourceDateFormatter.string(from: $0.endDate)
                }

                // DTO 생성
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

                        case .create:

                            // ① 알바 본인 등록
                            if self.userRole == .worker {
                                _ = try await self.workUseCase.createMyWork(
                                    workplaceId: workplace.id,
                                    requestDTO: createDTO
                                )
                            }
                            // ② 사장 본인 등록
                            else if self.userRole == .owner && workerIds.isEmpty {
                                _ = try await self.workUseCase.createMyWork(
                                    workplaceId: workplace.id,
                                    requestDTO: createDTO
                                )
                            }
                            // ③ 사장이 알바 등록
                            else if self.userRole == .owner && !workerIds.isEmpty {
                                let request = WorkersWorkCreateRequestDTO(
                                    workerIdList: workerIds,
                                    startTime: clockIn,
                                    actualStartTime: nil,
                                    endTime: clockOut,
                                    actualEndTime: nil,
                                    restTimeMinutes: breakMin,
                                    memo: memo,
                                    repeatDays: repeatInfo?.daysEN ?? [],
                                    repeatEndDate: repeatEndDateString
                                )

                                _ = try await self.workUseCase.createWorkersWork(
                                    workplaceId: workplace.id,
                                    requestDTO: request
                                )
                            }

                        case .edit(let workId):
                            try await self.workUseCase.updateMySingleWork(
                                workId: workId,
                                requestDTO: updateDTO
                            )
                        }

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
extension OLDWorkRegisterViewModel {

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
                            OLDRepeatInfo(
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
