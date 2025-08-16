//
//  CalendarViewModel.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import RxRelay
import RxSwift

/// 캘린더 VM
final class CalendarViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Input
    struct Input {
        let visibleYearMonth: Observable<(year: Int, month: Int)>
        let calendarMode: Observable<CalendarMode>
        let filterWorkplace: Observable<FilterWorkplace>
    }
    
    // MARK: - Output
    struct Output {
        let calendarEventList: Observable<[CalendarEvent]>
    }
    private let calendarEventListRelay = PublishRelay<[CalendarEvent]>()
    
    // MARK: - Initializer
    init() {
        // TODO: UseCase 주입
    }
    
    // MARK: - Input ➡️ Output Transform
    func transform(input: Input) -> Output {
        // TODO: 근무 이벤트 로딩
        Observable.combineLatest(input.visibleYearMonth, input.calendarMode, input.filterWorkplace)
            .subscribe(with: self) { owner, combined in
                let ((year, month), calendarMode, filterWorkplace) = combined
                let calendarEventList: [CalendarEvent]
                switch calendarMode {
                case .personal:
                    calendarEventList = CalendarMockData.personalCalendarEventListMock
                case .shared:
                    calendarEventList = CalendarMockData.sharedCalendarEventListMock
                }
                var filtered: [CalendarEvent] = []
                switch calendarMode {
                case .personal:
                    if filterWorkplace.workplaceId == -1 {
                        // 전체 보기
                        filtered = calendarEventList
                    } else {
                        filtered = calendarEventList.filter { $0.workplaceId == filterWorkplace.workplaceId }
                    }
                case .shared:
                    if filterWorkplace.workplaceId == -1 {
                        // 전체 보기
                        filtered = calendarEventList
                    } else {
                        filtered = calendarEventList.filter { $0.workplaceId == filterWorkplace.workplaceId }
                    }
                }
                owner.calendarEventListRelay.accept(filtered)
            }.disposed(by: disposeBag)
        return Output(calendarEventList: calendarEventListRelay.asObservable())
    }
}
