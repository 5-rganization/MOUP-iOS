//
//  SaveStrategy.swift
//  MOUP
//
//  Created by 신영 on 9/27/25.
//

import Foundation
import RxSwift

struct RoutineDraft {
    var title: String
    var alarm: DateComponents?
    var todos: [TodoItem]
}

protocol SaveStrategy {
    func save(_ draft: RoutineDraft) -> Completable
}

struct AddSaveStrategy: SaveStrategy {
    let createRoutineUseCase: CreateRoutineUseCase
    
    func save(_ draft: RoutineDraft) -> Completable {
        createRoutineUseCase.execute(
            title: draft.title,
            alarm: draft.alarm,
            todos: draft.todos
        )
    }
}

struct EditSaveStrategy: SaveStrategy {
    let updateRoutineUseCase: UpdateRoutineUseCase
    let routineID: UUID
    
    func save(_ draft: RoutineDraft) -> Completable {
        updateRoutineUseCase.execute(
            id: routineID,
            title: draft.title,
            alarm: draft.alarm,
            todos: draft.todos
        )
    }
}
