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
    let routine: Routine
    var isChecked: Bool
    
    var identity: UUID {
        return routine.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(routine.id)
    }
    
    static func == (lhs: RoutineRowViewState, rhs: RoutineRowViewState) -> Bool {
        lhs.routine.id == rhs.routine.id && lhs.isChecked == rhs.isChecked
    }
}

typealias RoutineSectionModel = AnimatableSectionModel<Int, RoutineRowViewState>

final class RoutineSelectionViewModel {
    struct Input {
        let appear: Observable<Void>
        let checkboxToggled: Observable<UUID>
        let addNewRoutine: Observable<Routine>
        let routineUpdated: Observable<Routine>
    }
    
    struct Output {
        let rows: Driver<[RoutineSectionModel]>
    }
    
    // MARK: - Properties
    
    private let routinesRelay = BehaviorRelay<[Routine]>(value: [])
    private let checkedIDsRelay = BehaviorRelay<Set<UUID>>(value: [])
    private let disposeBag = DisposeBag()
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        let initialRoutines = input.appear
            .flatMapLatest { [weak self] _ -> Observable<[Routine]> in
                guard let self else { return .empty() }
                // TODO: usecase 호출
                return .just(self.fetchDummyData())
            }
        
        let newRoutineAdded = input.addNewRoutine
            .withLatestFrom(routinesRelay) { newRoutine, currentRoutines in
                return currentRoutines + [newRoutine]
            }
        
        let routineUpdated = input.routineUpdated
            .withLatestFrom(routinesRelay) { updated, current -> [Routine] in
                current.map { $0.id == updated.id ? updated : $0 }
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
                        isChecked: checkedIDs.contains($0.id)
                    )
                }
                return [RoutineSectionModel(model: 0, items: viewStates)]
            }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
        
        return Output(
            rows: rows
        )
    }
    
    private func fetchDummyData() -> [Routine] {
        return [
            Routine(id: UUID(), title: "오픈", alarmTime: nil, items: []),
            Routine(id: UUID(), title: "폐기", alarmTime: nil, items: []),
            Routine(id: UUID(), title: "마감", alarmTime: nil, items: [])
        ]
    }
}
