//
//  MyWorkData.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

import Foundation

/// 내 근무 Entity
struct MyWorkData {
    let id: Int
    let workplaceSummary: WorkplaceSummary
    let workDate: String
    let repeatDays: [String]
    let repeatEndDate: String?
    let startTime: Date
    let actualStartTime: Date?
    let endTime: Date?
    let actualEndTime: Date?
    let restTimeMinutes: Int
    let routineSummaryList: [RoutineSummary]
    let memo: String?
}
