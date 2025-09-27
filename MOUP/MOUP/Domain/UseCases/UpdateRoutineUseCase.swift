//
//  UpdateRoutineUseCase.swift
//  MOUP
//
//  Created by 신영 on 9/27/25.
//

import Foundation
import RxSwift

struct UpdateRoutineUseCase {
    func execute(
        id: UUID,
        title: String,
        alarm: DateComponents?,
        todos: [TodoItem]
    ) -> Completable {
        return Completable.empty()
    }
}
