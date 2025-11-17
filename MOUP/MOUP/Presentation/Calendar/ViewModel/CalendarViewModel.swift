//
//  CalendarViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import OSLog

import RxRelay
import RxSwift

/// 캘린더 VM
final class CalendarViewModel {
    
    // MARK: - Properties
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    private let disposeBag = DisposeBag()
    
    // Initializer Injections
    private let workUseCase: WorkUseCaseProtocol
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    
    // Others
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Input
    struct Input {
        let baseFetchDate: Observable<Date>
        let calendarMode: Observable<CalendarMode>
        let personalFilterWorkplace: Observable<WorkplaceSummary?>
        let sharedFilterWorkplace: Observable<WorkplaceSummary?>
        let viewWillDisappear: Observable<Void>
    }
    
    // MARK: - Output
    struct Output {
        let calendarWorkDict: Observable<[Date: Set<WorkSummary>]>
        let errorMessage: Observable<(title: String, message: String)>
    }
    private let calendarWorkDictRelay = BehaviorRelay<[Date: Set<WorkSummary>]>(value: [:])
    private let errorMessageRelay = PublishRelay<(title: String, message: String)>()
    
    // MARK: - Initializer
    init(workUseCase: WorkUseCaseProtocol, workplaceUseCase: WorkplaceUseCaseProtocol) {
        self.workUseCase = workUseCase
        self.workplaceUseCase = workplaceUseCase
    }
    
    // MARK: - Input ➡️ Output Transform
    func transform(input: Input) -> Output {
        Observable.combineLatest(input.baseFetchDate, input.calendarMode, input.personalFilterWorkplace, input.sharedFilterWorkplace)
            .subscribe(with: self) { owner, combined in
                let (baseFetchDate, calendarMode, personalFilterWorkplace, sharedFilterWorkplace) = combined
                let baseYearMonth = DateFormatter.dataYearMonthDateFormatter.string(from: baseFetchDate)
                owner.fetchTask?.cancel()
                owner.fetchTask = Task {
                    do {
                        var calendarWorkList: [WorkSummary]
                        switch calendarMode {
                        case .personal:
                            if let filterWorkplace = personalFilterWorkplace {
                                calendarWorkList = try await owner.workUseCase.fetchWorkplaceMyWorkList(workplaceId: filterWorkplace.id, baseYearMonth: baseYearMonth)
                            } else {
                                calendarWorkList = try await owner.workUseCase.fetchAllMyWorkList(baseYearMonth: baseYearMonth)
                            }
                            try Task.checkCancellation()
                            
                        case .shared:
                            if let filterWorkplace = sharedFilterWorkplace {
                                calendarWorkList = try await owner.workUseCase.fetchWorkplaceAllWorkList(workplaceId: filterWorkplace.id, baseYearMonth: baseYearMonth)
                            } else {
                                let workplaceSummaryList = try await owner.workplaceUseCase.fetchSharedWorkplaceOnly()
                                try Task.checkCancellation()
                                
                                if let firstSharedWorkplaceId = workplaceSummaryList.sorted(by: { $0.name < $1.name }).first?.id {
                                    calendarWorkList = try await owner.workUseCase.fetchWorkplaceAllWorkList(workplaceId: firstSharedWorkplaceId, baseYearMonth: baseYearMonth)
                                    try Task.checkCancellation()
                                    
                                } else {
                                    calendarWorkList = []
                                }
                            }
                        }
                        
                        let newChunkDict = calendarWorkList.reduce(into: [Date: Set<WorkSummary>]()) { dict, work in
                            guard let workDate = DateFormatter.dataSourceDateFormatter.date(from: work.workDate) else { return }
                            dict[workDate, default: []].insert(work)
                        }
                        
                        // 근무 데이터 보존용 코드 (UI 깜빡임 방지)
                        let dateRange: ClosedRange<Date>? = {
                            guard let minDate = Calendar.current.date(byAdding: .month, value: -6, to: baseFetchDate),
                                  let maxDate = Calendar.current.date(byAdding: .month, value: 6, to: baseFetchDate),
                                  let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: minDate)) else { return nil }
                            
                            let endOfMonthStart = Calendar.current.dateComponents([.year, .month], from: maxDate)
                            guard let endOfMonthStartDate = Calendar.current.date(from: endOfMonthStart),
                                  let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: endOfMonthStartDate) else { return nil }
                            return startOfMonth...endOfMonth
                        }()
                        
                        var currentDict = owner.calendarWorkDictRelay.value
                        if let dateRange {
                            let datesToRemove = currentDict.keys.filter { dateRange.contains($0) }
                            datesToRemove.forEach { currentDict[$0] = nil }
                        }
                        currentDict.merge(newChunkDict) { _, newSet in newSet }
                        
                        await MainActor.run { [currentDict] in
                            owner.calendarWorkDictRelay.accept(currentDict)
                        }
                        
                    } catch is CancellationError {
                        owner.logger.info("캘린더 근무지(매장) 근무 로딩 Task가 취소되었습니다.")
                    } catch let error as LocalizedError {
                        await MainActor.run {
                            owner.errorMessageRelay.accept((title: "근무 불러오기 실패", message: error.errorDescription ?? "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                        }
                    } catch {
                        await MainActor.run {
                            owner.errorMessageRelay.accept((title: "근무 불러오기 실패", message: "오류가 발생하였습니다. 잠시 후 다시 시도해주세요."))
                        }
                    }
                }
            }.disposed(by: disposeBag)
        
        input.viewWillDisappear
            .subscribe(with: self) { owner, _ in
                owner.fetchTask?.cancel()
                owner.fetchTask = nil
            }.disposed(by: disposeBag)
        
        return Output(calendarWorkDict: calendarWorkDictRelay.asObservable(),
                      errorMessage: errorMessageRelay.asObservable())
    }
}
