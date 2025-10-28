//
//  DraftRoutine.swift
//  MOUP
//
//  Created by 신영 on 10/26/25.
//

import Foundation

struct DraftRoutine: Codable {
    let title: String
    let alarmTime: DateComponents?
    let items: [TodoItem]
    let savedAt: Date
}
