//
//  WorkSummary.swift
//  MOUP
//
//  Created by 서동환 on 8/14/25.
//

import Foundation

/// 근무 요약 Entity
struct WorkSummary: Hashable {
    let id: Int
    let workplaceSummary: WorkplaceSummary
    let workerSummary: WorkerSummary
    let workDate: String
    let startTime: Date
    let endTime: Date?
    let workMinutes: Int
    let restTimeMinutes: Int
    let estimatedNetIncome: Int?
    let repeatDays: [String]
    let repeatEndDate: String?
    let isMyWork: Bool
    let isEditable: Bool
    
    static func == (lhs: WorkSummary, rhs: WorkSummary) -> Bool { lhs.id == rhs.id }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
