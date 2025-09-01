//
//  CalendarViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import Foundation
import OSLog

import RxRelay
import RxSwift

/// 캘린더 VM
final class CalendarViewModel {
    
    // MARK: - Properties
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    private let disposeBag = DisposeBag()
    
    // MARK: - Input
    struct Input {
        let visibleDate: Observable<Date>
        let calendarMode: Observable<CalendarMode>
        let personalFilterWorkplace: Observable<FilterWorkplace?>
        let sharedFilterWorkplace: Observable<FilterWorkplace?>
    }
    
    // MARK: - Output
    struct Output {
        let calendarWorkList: Observable<[CalendarWork]>
    }
    private let calendarWorkListRelay = BehaviorRelay<[CalendarWork]>(value: [])
    
    // MARK: - Initializer
    init() {
        // TODO: UseCase 주입
    }
    
    // MARK: - Input ➡️ Output Transform
    func transform(input: Input) -> Output {
        // TODO: 근무 데이터 로딩 API 호출
        Observable.combineLatest(input.visibleDate, input.calendarMode, input.personalFilterWorkplace, input.sharedFilterWorkplace)
            .subscribe(with: self) { owner, combined in
                let (visibleDate, calendarMode, personalFilterWorkplace, sharedFilterWorkplace) = combined
                owner.logger.debug("근무 데이터 로딩 API 호출")
                
                var calendarWorkList: [CalendarWork]
                switch calendarMode {
                case .personal:
                    calendarWorkList = CalendarMockData.personalCalendarWorkListMock
                    if let personalFilterWorkplace {
                        calendarWorkList = calendarWorkList.filter { $0.workplaceId == personalFilterWorkplace.workplaceId }
                    }
                case .shared:
                    calendarWorkList = CalendarMockData.sharedCalendarWorkListMock
                    if let sharedFilterWorkplace {
                        calendarWorkList = calendarWorkList.filter { $0.workplaceId == sharedFilterWorkplace.workplaceId }
                    } else {
                        let firstWorkplaceId = calendarWorkList.sorted(by: { $0.workplaceName < $1.workplaceName }).first?.workplaceId
                        calendarWorkList = calendarWorkList.filter { $0.workplaceId == firstWorkplaceId }
                    }
                }
                calendarWorkList.sort(by: owner.sortCalendarWorkList)
                owner.calendarWorkListRelay.accept(calendarWorkList)
                owner.logger.debug("근무 데이터 로딩 완료")
            }.disposed(by: disposeBag)
        return Output(calendarWorkList: calendarWorkListRelay.asObservable())
    }
}

// MARK: - Private Methods
private extension CalendarViewModel {
    func sortCalendarWorkList(_ lhs: CalendarWork, _ rhs: CalendarWork) -> Bool {
        return (lhs.startTime, lhs.endTime) < (rhs.startTime, rhs.endTime)
    }
}
