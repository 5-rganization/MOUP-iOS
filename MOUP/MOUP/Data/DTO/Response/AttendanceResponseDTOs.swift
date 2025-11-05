//
//  AttendanceResponseDTOs.swift
//  MOUP
//
//  Created by 송규섭 on 11/4/25.
//

import Foundation

/// 근무자 근무 내역
struct WorkerAttendanceSummaryDTO: Decodable {
    let workId: Int
    let workDate: String
    let startTime: String
    let actualStartTime: String?
    let endTime: String?
    let actualEndTime: String?
}

/// 사장님 전용 근태 조회 결과
struct OwnerWorkplaceAttendanceHistoryDTO: Decodable {
    let workplaceId: Int
    let workerId: Int
    let workerWorkAttendanceInfoList: [WorkerAttendanceSummaryDTO]
}

/// 알바생 전용 근태 조회 결과
struct WorkerWorkplaceAttendanceHistoryDTO: Decodable {
    let myWorkAttendanceInfoList: [WorkerAttendanceSummaryDTO]
}

/// 근무지에 속한 근무자들 조회 결과
struct WorkplaceWorkersResponseDTO: Decodable {
    let workerSummaryInfoList: [WorkerSummaryResponseDTO]
}
