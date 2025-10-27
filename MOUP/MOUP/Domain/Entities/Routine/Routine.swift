//
//  Routine.swift
//  MOUP
//
//  Created by 송규섭 on 10/5/25.
//

import Foundation

struct Routine: Hashable {
    let id: UUID
    let title: String
    let alarmTime: DateComponents?
    let items: [TodoItem]
}
