//
//  RoutineSelectionViewModel.swift
//  MOUP
//
//  Created by shinyoungkim on 9/14/25.
//

import Foundation
import RxSwift
import RxCocoa

struct DummyRoutine {
    let id: String
    let name: String
    let time: String
}

struct RoutineRowViewState: Hashable {
    let id: String
    let name: String
    let time: String
    let isChecked: Bool
}

final class RoutineSelectionViewModel {
    struct Input {
        let appear: Observable<Void>
        let checkboxToggled: Observable<(index: IndexPath, toggled: Bool)>
    }
    
    struct Output {
        let rows: Driver<[RoutineRowViewState]>
    }
    
    // MARK: - Properties
    
    private let rowsRelay = BehaviorRelay<[RoutineRowViewState]>(value: [])
    private let disposeBag = DisposeBag()
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        input.appear
            .map { _ -> [DummyRoutine] in
                return [
                    DummyRoutine(id: "open", name: "오픈", time: "09 : 00"),
                    DummyRoutine(id: "waste", name: "폐기", time: "15 : 00"),
                    DummyRoutine(id: "close", name: "마감", time: "18 : 00")
                ]
            }
            .map { routines in
                routines.map {
                    RoutineRowViewState(id: $0.id, name: $0.name, time: $0.time, isChecked: false)
                }
            }
            .bind(to: rowsRelay)
            .disposed(by: disposeBag)
        
        input.checkboxToggled
            .withLatestFrom(rowsRelay.asObservable()) { toggle, rows -> [RoutineRowViewState] in
                var newRows = rows
                if toggle.index.row < newRows.count {
                    let old = newRows[toggle.index.row]
                    newRows[toggle.index.row] = RoutineRowViewState(
                        id: old.id, name: old.name, time: old.time, isChecked: toggle.toggled
                    )
                }
                return newRows
            }
            .bind(to: rowsRelay)
            .disposed(by: disposeBag)
        
        return Output(rows: rowsRelay.asDriver())
    }
}
