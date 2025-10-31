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
    private let routineUseCase: RoutineUseCaseProtocol
    private let todayRoutineRelay = BehaviorRelay<[TodayRoutineItem]>(value: [])
    private let errorMessageRelay = PublishRelay<(title: String, message: String)>()
    
    init(routineUseCase: RoutineUseCaseProtocol) {
        self.routineUseCase = routineUseCase
    }
    
    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let todayRoutine: Observable<[TodayRoutineItem]>
        let errorMessage: Observable<(title: String, message: String)>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.fetchTodayRoutines()
            })
            .disposed(by: disposeBag)
        
        return Output(
            todayRoutine: todayRoutineRelay.asObservable(),
            errorMessage: errorMessageRelay.asObservable()
        )
    }
    
}

private extension TodayRoutineViewModel {
    func fetchTodayRoutines() {
        Task {
            do {
                let todayRoutines = try await routineUseCase.fetchTodayRoutines()
                let todayRoutineItem = TodayRoutineItem(items: todayRoutines)
                todayRoutineRelay.accept([todayRoutineItem])
            } catch {
                errorMessageRelay.accept(("루틴 불러오기 실패", "오늘의 루틴을 불러오지 못했습니다.\n잠시 후 다시 시도해주세요."))
            }
        }
    }
}
