//
//  WorkData.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

import Foundation

/// 근무 전체 정보 Entity
struct WorkData {
    let id: Int
    let workplaceSummary: WorkplaceSummary
    let workerSummary: WorkerSummary
    let routineSummaryList: [RoutineSummary]
    let workDate: String
    let startTime: Date
    let actualStartTime: Date?
    let endTime: Date?
    let actualEndTime: Date?
    let restTimeMinutes: Int
    let workMinutes: Int
    let memo: String?
    let repeatDays: [String]
    let repeatEndDate: String?
    let isMyWork: Bool
    let isEditable: Bool
}

extension WorkData {
    func toMyWorkData() -> MyWorkData {
        MyWorkData(id: id,
                   workplaceSummary: workplaceSummary,
                   workDate: workDate,
                   repeatDays: repeatDays,
                   repeatEndDate: repeatEndDate,
                   startTime: startTime,
                   actualStartTime: actualStartTime,
                   endTime: endTime,
                   actualEndTime: actualEndTime,
                   restTimeMinutes: restTimeMinutes,
                   routineSummaryList: routineSummaryList,
                   memo: memo)
    }
    
    func toWorkerWorkData() -> WorkerWorkData {
        WorkerWorkData(
            id: id,
            workplaceSummary: workplaceSummary,
            workerSummary: workerSummary,
            routineSummaryInfoList: routineSummaryList,
            workDate: workDate,
            repeatDays: repeatDays,
            repeatEndDate: repeatEndDate,
            startTime: startTime,
            actualStartTime: actualStartTime,
            endTime: endTime,
            actualEndTime: actualEndTime,
            restTimeMinutes: restTimeMinutes,
            memo: memo,
            isMyWork: isMyWork
        )
    }

}
