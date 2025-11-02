//
//  RoutineRequestDTOs.swift
//  MOUP
//
//  Created by 신영 on 11/2/25.
//

import Foundation

struct CreateRoutineRequestDTO: Encodable {
    let routineName: String
    let alarmTime: String
    let routineTaskList: [RoutineTaskDTO]
}

struct RoutineTaskDTO: Encodable {
    let content: String
    let orderIndex: Int
}
