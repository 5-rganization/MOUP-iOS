//
//  WorkRequestDTOs.swift
//  MOUP
//
//  Created by 서동환 on 10/29/25.
//

import Foundation

/// 사용자 근무 생성 요청 DTO
struct MyWorkCreateRequestDTO: Encodable {
    let routineIdList: [Int]
    let startTime: Date
    let actualStartTime: Date?
    let endTime: Date
    let actualEndTime: Date?
    let restTimeMinutes: Int
    let memo: String?
    let repeatDays: [String]
    let repeatEndDate: String?
}

/// 사용자 근무 업데이트 요청 DTO
struct MyWorkUpdateRequestDTO: Encodable {
    let routineIdList: [Int]
    let startTime: Date
    let actualStartTime: Date?
    let endTime: Date
    let actualEndTime: Date?
    let restTimeMinutes: Int
    let memo: String?
    let repeatDays: [String]
    let repeatEndDate: String?
}

/// 근무자 근무 생성 요청 DTO (사장님 전용)
struct WorkerWorkCreateRequestDTO: Encodable {
    let startTime: Date
    let actualStartTime: Date?
    let endTime: Date
    let actualEndTime: Date?
    let restTimeMinutes: Int
    let memo: String?
    let repeatDays: [String]
    let repeatEndDate: String?
}

/// 근무자 근무 업데이트 요청 DTO (사장님 전용)
struct WorkerWorkUpdateRequestDTO: Encodable {
    let startTime: Date
    let actualStartTime: Date?
    let endTime: Date
    let actualEndTime: Date?
    let restTimeMinutes: Int
    let memo: String?
    let repeatDays: [String]
    let repeatEndDate: String?
}
