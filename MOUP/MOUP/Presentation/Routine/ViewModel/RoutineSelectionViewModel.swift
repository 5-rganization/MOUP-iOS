//
//  RoutineSelectionViewModel.swift
//  MOUP
//
//  Created by shinyoungkim on 9/14/25.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

struct RoutineRowViewState: IdentifiableType, Hashable {
    let routine: RoutineSummary
    var isChecked: Bool
    
    var identity: Int {
        return routine.routineId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(routine.routineId)
    }
    
    static func == (lhs: RoutineRowViewState, rhs: RoutineRowViewState) -> Bool {
        lhs.routine.routineId == rhs.routine.routineId &&
        lhs.routine.routineName == rhs.routine.routineName &&
        lhs.routine.alarmTime == rhs.routine.alarmTime &&
        lhs.isChecked == rhs.isChecked
    }
}

typealias RoutineSectionModel = AnimatableSectionModel<Int, RoutineRowViewState>

final class RoutineSelectionViewModel {
    struct Input {
        let appear: Observable<Void>
        let checkboxToggled: Observable<Int>
        let addNewRoutine: Observable<RoutineSummary>
        let routineUpdated: Observable<RoutineSummary>
        let applyButtonTapped: Observable<Void>
    }
    
    struct Output {
        let rows: Driver<[RoutineSectionModel]>
        let error: Signal<String>
        let selectedRoutineIDs: Signal<[Int]>
    }
    
    // MARK: - Properties
    
    private let routineUseCase: RoutineUseCaseProtocol
    private let routinesRelay = BehaviorRelay<[RoutineSummary]>(value: [])
    private let checkedIDsRelay = BehaviorRelay<Set<Int>>(value: [])
    private let errorRelay = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(routineUseCase: RoutineUseCaseProtocol) {
        self.routineUseCase = routineUseCase
    }
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        let initialRoutines = input.appear
            .flatMapLatest { [weak self] _ -> Observable<[RoutineSummary]> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    Task {
                        do {
                            let routines = try await self.routineUseCase.fetchAllRoutines()
                            observer.onNext(routines)
                            observer.onCompleted()
                        } catch {
                            self.errorRelay.accept("루틴 목록을 불러오는데 실패했습니다.")
                            observer.onNext([])
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
        
        let newRoutineAdded = input.addNewRoutine
            .withLatestFrom(routinesRelay) { newRoutine, currentRoutines in
                return currentRoutines + [newRoutine]
            }
        
        let routineUpdated = input.routineUpdated
            .withLatestFrom(routinesRelay) { updated, current -> [RoutineSummary] in
                current.map { $0.routineId == updated.routineId ? updated : $0 }
            }
        
        Observable.merge(initialRoutines, newRoutineAdded, routineUpdated)
            .bind(to: routinesRelay)
            .disposed(by: disposeBag)
        
        input.checkboxToggled
            .withLatestFrom(checkedIDsRelay) { toggledID, currentIDs in
                currentIDs.symmetricDifference([toggledID])
            }
            .bind(to: checkedIDsRelay)
            .disposed(by: disposeBag)
        
        let rows = Observable
            .combineLatest(routinesRelay, checkedIDsRelay)
            .map { routines, checkedIDs -> [RoutineSectionModel] in
                let viewStates = routines.map {
                    RoutineRowViewState(
                        routine: $0,
                        isChecked: checkedIDs.contains($0.routineId)
                    )
                }
                return [RoutineSectionModel(model: 0, items: viewStates)]
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
        
        let selectedRoutineIDs = input.applyButtonTapped
            .withLatestFrom(checkedIDsRelay)
            .map { Array($0).sorted() }
            .asSignal(onErrorJustReturn: [])
        
        return Output(
            rows: rows,
            error: errorRelay.asSignal(),
            selectedRoutineIDs: selectedRoutineIDs
        )
    }
}
