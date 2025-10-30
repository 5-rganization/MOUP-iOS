//
//  WorkResponseDTOs.swift
//  MOUP
//
//  Created by 서동환 on 10/28/25.
//

import Foundation

/// 근무 생성 응답 DTO
struct WorkCreateResponseDTO: Decodable {
    let workId: [Int]
}

/// 근무 상세 정보 응답 DTO
struct WorkDetailResponseDTO: Decodable {
    let workId: Int
    let workerSummaryInfo: WorkerSummaryResponseDTO
    let workplaceSummaryInfo: WorkplaceSummaryResponseDTO
    let routineSummaryInfoList: [RoutineSummaryResponseDTO]
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

/// 근무 요약 정보 응답 DTO
struct WorkSummaryResponseDTO: Decodable {
    let workId: Int
    let workerSummaryInfo: WorkerSummaryResponseDTO
    let workplaceSummaryInfo: WorkplaceSummaryResponseDTO
    let workDate: String
    let startTime: String
    let endTime: String?
    let workMinutes: Int
    let restTimeMinutes: Int
    let estimatedNetIncome: Int
    let repeatDays: [String]
    let repeatEndDate: String?
    let isMyWork: Bool
    let isEditable: Bool
}

/// 캘린더용 근무 정보 응답 DTO
struct WorkCalendarListResponseDTO: Decodable {
    let workSummaryInfoList: [WorkSummaryResponseDTO]
}
