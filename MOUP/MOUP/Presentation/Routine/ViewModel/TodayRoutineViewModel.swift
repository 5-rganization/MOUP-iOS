//
//  TodayRoutineViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 10/5/25.
//

import Foundation
import RxSwift
import RxRelay

final class TodayRoutineViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let todayRoutineRelay = BehaviorRelay<[TodayRoutineItem]>(value: [])
    private let mockTodayRoutines = [
        TodayRoutineItem(
            items: [
                TodayRoutine(
                    workplaceName: "GS25 한신점",
                    routines: [Routine(
                        id: UUID(),
                        title: "치킨",
                        alarmTime: DateComponents(hour: 10, minute: 0),
                        items: [
                            TodoItem(text: "바삭통다리 2개"),
                            TodoItem(text: "매운바삭치킨 2개")
                        ]
                    ),
                               Routine(
                                id: UUID(),
                                title: "청소",
                                alarmTime: DateComponents(hour: 14, minute: 30),
                                items: [
                                    TodoItem(text: "내부 테이블 정리"),
                                    TodoItem(text: "외부 테라스 분리수거")
                                ]
                               )
                    ]
                )
            ]
        )
    ]
    
    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let todayRoutine: Observable<[TodayRoutineItem]>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.todayRoutineRelay.accept(owner.mockTodayRoutines)
            })
            .disposed(by: disposeBag)
        
        return Output(
            todayRoutine: todayRoutineRelay.asObservable()
        )
    }
    
}
