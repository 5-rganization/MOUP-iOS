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
        let currMonth: Observable<(year: Int, month: Int)>
        let selectedCalendarMode: Observable<CalendarMode>
    }
    
    // MARK: - Output
    struct Output {
        let calendarModelList: Observable<(personal: [CalendarEvent], shared: [CalendarEvent])>
    }
    private let calendarModelListRelay = PublishRelay<(personal: [CalendarEvent], shared: [CalendarEvent])>()
    
    // MARK: - Input ➡️ Output Transform
    func transform(input: Input) -> Output {
        // TODO: 근무 이벤트 로딩
        calendarModelListRelay.accept(CalendarMockData.calendarEventListMock)
        return Output(calendarModelList: calendarModelListRelay.asObservable())
    }
}
