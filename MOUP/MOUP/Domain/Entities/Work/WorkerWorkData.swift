//
//  WorkerWorkData.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

import Foundation

/// 근무자 근무 Entity
struct WorkerWorkData {
    let id: Int
    let workplaceSummary: WorkplaceSummary
    let workerSummary: WorkerSummary
    let routineSummaryInfoList: [RoutineSummary]
    let workDate: String
    let repeatDays: [String]
    let repeatEndDate: String?
    let startTime: Date
    let actualStartTime: Date?
    let endTime: Date?
    let actualEndTime: Date?
    let restTimeMinutes: Int
    let memo: String?
}
