//
//  RoutineSelectionViewModel.swift
//  MOUP
//
//  Created by shinyoungkim on 9/14/25.
//

import Foundation
import RxSwift
import RxCocoa

struct Routine: Hashable {
    let id: UUID
    let title: String
    let alarmTime: DateComponents?
    let items: [TodoItem]
}

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
        
        Observable.merge(initialRoutines, newRoutineAdded)
            .bind(to: routinesRelay)
            .disposed(by: disposeBag)
        
        input.checkboxToggled
            .withLatestFrom(checkedIDsRelay) { toggledID, current -> (UUID, Set<UUID>) in
                var next = current
                if next.contains(toggledID) { next.remove(toggledID) } else { next.insert(toggledID) }
                return (toggledID, next)
            }
            .subscribe(onNext: { [weak self] toggledID, next in
                guard let self else { return }
                self.checkedIDsRelay.accept(next)
                if let routine = self.routinesRelay.value.first(where: { $0.id == toggledID }) {
                    let vs = RoutineRowViewState(routine: routine, isChecked: next.contains(toggledID))
                    toggledRowRelay.accept(vs)
                }
            })
            .disposed(by: disposeBag)
        
        let rows = Observable
            .combineLatest(routinesRelay.asObservable(), checkedIDsRelay.asObservable())
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
