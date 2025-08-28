//
//  CalendarViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import Foundation

import RxRelay
import RxSwift

/// 캘린더 VM
final class CalendarViewModel {
    
    // MARK: - Properties
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
        let calendarEventList: Observable<[CalendarEvent]>
    }
    private let calendarEventListRelay = BehaviorRelay<[CalendarEvent]>(value: [])
    
    // MARK: - Initializer
    init() {
        // TODO: UseCase 주입
    }
    
    // MARK: - Input ➡️ Output Transform
    func transform(input: Input) -> Output {
        // TODO: 근무 이벤트 로딩
        Observable.combineLatest(input.visibleDate, input.calendarMode, input.personalFilterWorkplace, input.sharedFilterWorkplace)
            .subscribe(with: self) { owner, combined in
                let (visibleDate, calendarMode, personalFilterWorkplace, sharedFilterWorkplace) = combined
                var calendarEventList: [CalendarEvent]
                switch calendarMode {
                case .personal:
                    calendarEventList = CalendarMockData.personalCalendarEventListMock
                    if let personalFilterWorkplace {
                        calendarEventList = calendarEventList.filter { $0.workplaceId == personalFilterWorkplace.workplaceId }
                    }
                case .shared:
                    calendarEventList = CalendarMockData.sharedCalendarEventListMock
                    if let sharedFilterWorkplace {
                        calendarEventList = calendarEventList.filter { $0.workplaceId == sharedFilterWorkplace.workplaceId }
                    } else {
                        let firstWorkplaceId = calendarEventList.sorted(by: { $0.workplaceName < $1.workplaceName }).first?.workplaceId
                        calendarEventList = calendarEventList.filter { $0.workplaceId == firstWorkplaceId }
                    }
                }
                calendarEventList.sort(by: owner.sortCalendarEventList)
                owner.calendarEventListRelay.accept(calendarEventList)
            }.disposed(by: disposeBag)
        return Output(calendarEventList: calendarEventListRelay.asObservable())
    }
}

private extension CalendarViewModel {
    func sortCalendarEventList(_ lhs: CalendarEvent, _ rhs: CalendarEvent) -> Bool {
        return lhs.startTime < rhs.startTime || lhs.endTime < rhs.endTime
    }
}
