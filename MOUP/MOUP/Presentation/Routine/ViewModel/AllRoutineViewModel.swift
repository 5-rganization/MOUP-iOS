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
    private let routineUseCase: RoutineUseCaseProtocol
    private let allRoutinesRelay = BehaviorRelay<[RoutineItem]>(value: [])
    private let errorMessageRelay = PublishRelay<(title: String, message: String)>()
    
    // MARK: - Initializer
    init(routineUseCase: RoutineUseCaseProtocol) {
        self.routineUseCase = routineUseCase
    }
    
    // MARK: - Input, Output
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let allRoutines: Observable<[RoutineItem]>
        let errorMessage: Observable<(title: String, message: String)>
    }
    
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.fetchAllRoutines()
            })
            .disposed(by: disposeBag)
        
        return Output(
            allRoutines: allRoutinesRelay.asObservable(),
            errorMessage: errorMessageRelay.asObservable()
        )
    }
    
}

private extension AllRoutineViewModel {
    func fetchAllRoutines() {
        Task {
            do {
                let routines = try await routineUseCase.fetchAllRoutines()
                allRoutinesRelay.accept([RoutineItem(items: routines)])
            } catch {
                errorMessageRelay.accept(("루틴 불러오기 실패", "전체 루틴을 불러오지 못했습니다.\n잠시 후 다시 시도해주세요."))
            }
        }
    }
}
