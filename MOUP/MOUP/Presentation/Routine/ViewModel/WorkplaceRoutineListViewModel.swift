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
    private let routineUseCase: RoutineUseCaseProtocol
    private let routinesRelay = BehaviorRelay<[RoutineItem]>(value: [])
    private let errorMessageRelay = PublishRelay<(title: String, message: String)>()
    
    // MARK: - Initializer
    init(routineUseCase: RoutineUseCaseProtocol) {
        self.routineUseCase = routineUseCase
    }
    
    // MARK: - Input, Output
    struct Input {
        let workId: Observable<Int>
    }
    
    struct Output {
        let routineItem: Observable<[RoutineItem]>
        let errorMessage: Observable<(title: String, message: String)>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.workId
            .withUnretained(self)
            .subscribe(onNext: { owner, id in
                owner.fetchWorkRoutines(workId: id)
            })
            .disposed(by: disposeBag)
        
        return Output(
            routineItem: routinesRelay.asObservable(),
            errorMessage: errorMessageRelay.asObservable()
        )
    }
}

private extension WorkplaceRoutineListViewModel {
    func fetchWorkRoutines(workId: Int) {
        Task {
            do {
                let routines = try await routineUseCase.fetchWorkRoutines(workId: workId)
                routinesRelay.accept([
                    RoutineItem(items: routines)
                ])
            } catch {
                errorMessageRelay.accept(("루틴 불러오기 실패", "오늘의 루틴을 불러오지 못했습니다.\n잠시 후 다시 시도해주세요."))
            }
        }
    }
}
