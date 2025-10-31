//
//  WorkResponseDTOs.swift
//  MOUP
//
//  Created by 서동환 on 10/28/25.
//

import Foundation

/// 근무 생성 응답 DTO
struct WorkCreateResponseDTO: Decodable {
    let workIdList: [Int]
}

/// 근무자들에 대한 근무 생성 응답 DTO
struct WorkersWorkCreateResponseDTO: Decodable {
    let successWorkIdList: [Int]
    let failedWorkerInfoList: [FailedWorkerInfoDTO]
}

/// 근무 생성에 실패한 근무자 정보 DTO
struct FailedWorkerInfoDTO: Decodable {
    let workerId: Int
    let nickname: String
    let reason: String
}

extension FailedWorkerInfoDTO {
    func toDomain() -> FailedWorkerInfo {
        FailedWorkerInfo(nickname: nickname, reason: reason)
    }
}

/// 근무 상세 정보 응답 DTO
struct WorkDetailResponseDTO: Decodable {
    let workId: Int
    let workerSummaryInfo: WorkerSummaryResponseDTO
    let workplaceSummaryInfo: WorkplaceSummaryInfoDTO
    let routineSummaryInfoList: [RoutineSummaryDTO]
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

extension WorkDetailResponseDTO {
    func toDomain() -> WorkData {
        WorkData(id: workId,
                 workplaceSummary: WorkplaceSummary(id: workplaceSummaryInfo.workplaceId, name: workplaceSummaryInfo.workplaceName, isShared: workplaceSummaryInfo.isShared),
                 workerSummary: workerSummaryInfo.toDomain(),
                 routineSummaryList: routineSummaryInfoList.map { RoutineSummary(routineId: $0.routineId, routineName: $0.routineName, alarmTime: $0.alarmTime) },
                 workDate: workDate,
                 startTime: startTime,
                 actualStartTime: actualStartTime,
                 endTime: endTime,
                 actualEndTime: actualEndTime,
                 restTimeMinutes: restTimeMinutes,
                 workMinutes: workMinutes,
                 memo: memo,
                 repeatDays: repeatDays,
                 repeatEndDate: repeatEndDate,
                 isMyWork: isMyWork,
                 isEditable: isEditable)
    }
}

/// 근무 요약 정보 응답 DTO
struct WorkSummaryResponseDTO: Decodable {
    let workId: Int
    let workerSummaryInfo: WorkerSummaryResponseDTO
    let workplaceSummaryInfo: WorkplaceSummaryInfoDTO
    let workDate: String
    let startTime: Date
    let endTime: Date?
    let workMinutes: Int
    let restTimeMinutes: Int
    let estimatedNetIncome: Int
    let repeatDays: [String]
    let repeatEndDate: String?
    let isMyWork: Bool
    let isEditable: Bool
}

extension WorkSummaryResponseDTO {
    func toDomain() -> WorkSummary {
        WorkSummary(id: workId,
                    workplaceSummary: WorkplaceSummary(id: workplaceSummaryInfo.workplaceId, name: workplaceSummaryInfo.workplaceName, isShared: workplaceSummaryInfo.isShared),
                    workerSummary: workerSummaryInfo.toDomain(),
                    workDate: workDate,
                    startTime: startTime,
                    endTime: endTime,
                    workMinutes: workMinutes,
                    restTimeMinutes: restTimeMinutes,
                    estimatedNetIncome: estimatedNetIncome,
                    repeatDays: repeatDays,
                    repeatEndDate: repeatEndDate,
                    isMyWork: isMyWork,
                    isEditable: isEditable)
    }
}

/// 캘린더용 근무 정보 응답 DTO
struct WorkCalendarListResponseDTO: Decodable {
    let workSummaryInfoList: [WorkSummaryResponseDTO]
}
