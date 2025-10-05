//
//  RoutineSelectionViewModel.swift
//  MOUP
//
//  Created by shinyoungkim on 9/14/25.
//

import Foundation
import RxSwift
import RxCocoa

struct RoutineRowViewState: Hashable {
    let routine: Routine
    var isChecked: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(routine.id)
    }
    
    static func == (lhs: RoutineRowViewState, rhs: RoutineRowViewState) -> Bool {
        lhs.routine.id == rhs.routine.id
    }
}

final class RoutineSelectionViewModel {
    struct Input {
        let appear: Observable<Void>
        let checkboxToggled: Observable<UUID>
        let addNewRoutine: Observable<Routine>
        let routineUpdated: Observable<Routine>
    }
    
    struct Output {
        let rows: Driver<[RoutineRowViewState]>
        let toggledRow: Signal<RoutineRowViewState>
    }
    
    // MARK: - Properties
    
    private let routinesRelay = BehaviorRelay<[Routine]>(value: [])
    private let checkedIDsRelay = BehaviorRelay<Set<UUID>>(value: [])
    private let disposeBag = DisposeBag()
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        let toggledRowRelay = PublishRelay<RoutineRowViewState>()
        
        let initialRoutines = input.appear
            .flatMapLatest { [unowned self] _ -> Observable<[Routine]> in
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
        
        let checkboxToggleEvent = input.checkboxToggled
            .withLatestFrom(checkedIDsRelay) { toggledID, currentIDs -> (toggledID: UUID, newIDs: Set<UUID>) in
                let newCheckedIDs = currentIDs.symmetricDifference([toggledID])
                return (toggledID, newCheckedIDs)
            }
            .share()
        
        checkboxToggleEvent
            .map { $0.newIDs }
            .bind(to: checkedIDsRelay)
            .disposed(by: disposeBag)
        
        checkboxToggleEvent
            .withLatestFrom(routinesRelay) { toggleInfo, routines -> RoutineRowViewState? in
                guard let routine = routines.first(
                    where: { $0.id == toggleInfo.toggledID }
                ) else {
                    return nil
                }
                let isChecked = toggleInfo.newIDs.contains(toggleInfo.toggledID)
                return RoutineRowViewState(routine: routine, isChecked: isChecked)
            }
            .compactMap { $0 }
            .bind(to: toggledRowRelay)
            .disposed(by: disposeBag)
        
        let rows = Observable
            .combineLatest(routinesRelay, checkedIDsRelay)
            .map { routines, checked in
                routines.map { RoutineRowViewState(routine: $0, isChecked: checked.contains($0.id)) }
            }
            .asDriver(onErrorJustReturn: [])
        
        return Output(
            rows: rows,
            toggledRow: toggledRowRelay.asSignal()
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
