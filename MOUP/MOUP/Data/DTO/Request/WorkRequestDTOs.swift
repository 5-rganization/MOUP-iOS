//
//  WorkRequestDTOs.swift
//  MOUP
//
//  Created by 서동환 on 10/29/25.
//

import Foundation

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
