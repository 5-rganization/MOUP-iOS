//
//  AllRoutineViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 10/5/25.
//

import Foundation
import RxSwift
import RxRelay

final class AllRoutineViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let mockAllRoutines = [RoutineItem(items: [
        Routine(id: UUID(), title: "폐기", alarmTime: DateComponents(hour: 13, minute: 30), items: [
            TodoItem(text: "pp 매대 유통기한 검수"),
            TodoItem(text: "빵 라인 유통기한 검수")
        ]),
        Routine(id: UUID(), title: "치킨", alarmTime: DateComponents(hour: 10, minute: 0), items: [
            TodoItem(text: "바삭통다리 2개"),
            TodoItem(text: "더큰지파이 2개"),
            TodoItem(text: "치즈볼 3개")
        ])
    ])]
    private let allRoutinesRelay = BehaviorRelay<[RoutineItem]>(value: [])
    
    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let allRoutines: Observable<[RoutineItem]>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.allRoutinesRelay.accept(owner.mockAllRoutines)
            })
            .disposed(by: disposeBag)
        
        return Output(
            allRoutines: allRoutinesRelay.asObservable()
        )
    }
    
}
