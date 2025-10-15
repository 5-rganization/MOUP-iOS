//
//  WorkplaceRoutineListViewModel.swift
//  MOUP
//
//  Created by 송규섭 on 10/6/25.
//

import Foundation
import RxSwift
import RxRelay

final class WorkplaceRoutineListViewModel {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let routinesRelay = BehaviorRelay<[RoutineItem]>(value: [])
    
    // MARK: - Initializer
    
    // MARK: - Input, Output
    struct Input {
        let routines: Observable<[Routine]>
    }
    
    struct Output {
        let routineItem: Observable<[RoutineItem]>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.routines
            .withUnretained(self)
            .subscribe(onNext: { owner, routines in
                let routineItem = [
                    RoutineItem(items: routines)
                ]
                owner.routinesRelay.accept(routineItem)
            })
            .disposed(by: disposeBag)
        
        return Output(
            routineItem: routinesRelay.asObservable()
        )
    }
    
}
