//
//  CreateRoutineUseCase.swift
//  MOUP
//
//  Created by 신영 on 9/27/25.
//

import Foundation
import RxSwift

struct CreateRoutineUseCase {
    func execute(
        title: String,
        alarm: DateComponents?,
        todos: [TodoItem]
    ) -> Completable {
        return Completable.empty()
    }
}
