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
    
    // MARK: - Input
    struct Input {
        let visibleDate: Observable<Date>
        let calendarMode: Observable<CalendarMode>
        let personalFilterWorkplace: Observable<WorkplaceSummary?>
        let sharedFilterWorkplace: Observable<WorkplaceSummary?>
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
        Observable.combineLatest(input.visibleDate, input.calendarMode, input.personalFilterWorkplace, input.sharedFilterWorkplace)
            .subscribe(with: self) { owner, combined in
                let (visibleDate, calendarMode, personalFilterWorkplace, sharedFilterWorkplace) = combined
                let baseYearMonth = DateFormatter.dataYearMonthDateFormatter.string(from: visibleDate)
                
                Task.detached {
                    do {
                        var calendarWorkList: [WorkSummary]
                        switch calendarMode {
                        case .personal:
                            if let filterWorkplace = personalFilterWorkplace {
                                calendarWorkList = try await owner.workUseCase.fetchWorkplaceMyWorkList(workplaceId: filterWorkplace.id, baseYearMonth: baseYearMonth)
                            } else {
                                calendarWorkList = try await owner.workUseCase.fetchAllMyWorkList(baseYearMonth: baseYearMonth)
                            }
                        case .shared:
                            if let filterWorkplace = sharedFilterWorkplace {
                                calendarWorkList = try await owner.workUseCase.fetchWorkplaceAllWorkList(workplaceId: filterWorkplace.id, baseYearMonth: baseYearMonth)
                            } else {
                                let workplaceSummaryList = try await owner.workplaceUseCase.fetchSharedWorkplaceOnly()
                                if let firstSharedWorkplaceId = workplaceSummaryList.sorted(by: { $0.name < $1.name }).first?.id {
                                    calendarWorkList = try await owner.workUseCase.fetchWorkplaceAllWorkList(workplaceId: firstSharedWorkplaceId, baseYearMonth: baseYearMonth)
                                } else {
                                    calendarWorkList = []
                                }
                            }
                        }
                        
                        let newChunkDict = calendarWorkList.reduce(into: [Date: Set<WorkSummary>]()) { dict, work in
                            guard let workDate = DateFormatter.dataSourceDateFormatter.date(from: work.workDate) else { return }
                            dict[workDate, default: []].insert(work)
                        }
                        await MainActor.run {
                            var currentDict = owner.calendarWorkDictRelay.value
                            currentDict.merge(newChunkDict) { oldSet, newSet in oldSet.union(newSet) }
                            owner.calendarWorkDictRelay.accept(currentDict)
                        }
                        
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
        
        return Output(calendarWorkDict: calendarWorkDictRelay.asObservable(),
                      errorMessage: errorMessageRelay.asObservable())
    }
}
