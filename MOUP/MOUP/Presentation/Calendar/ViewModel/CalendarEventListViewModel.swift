//
//  CalendarEventListViewModel.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import RxRelay
import RxSwift

final class CalendarEventListViewModel {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // Initializer Injections
    private var calendarEventList: [CalendarEvent] = []
    
    // MARK: - Input
    struct Input {
        let viewDidLoad: Observable<Void>
        let deleteEventId: Observable<Int64>
    }
    
    // MARK: - Output
    struct Output {
        let calendarEventList: Observable<[CalendarEvent]>
    }
    private let calendarEventListRelay = BehaviorRelay<[CalendarEvent]>(value: [])
    
    // MARK: - Initializer
    init(calendarEventList: [CalendarEvent]) {
        self.calendarEventList = calendarEventList
        // TODO: UseCase 주입
    }
    
    // MARK: - Input ➡️ Output Transform
    func transform(input: Input) -> Output {
        // TODO: 근무 이벤트 로딩
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                owner.calendarEventListRelay.accept(owner.calendarEventList)
            }.disposed(by: disposeBag)
        return Output(calendarEventList: calendarEventListRelay.asObservable())
    }
}
