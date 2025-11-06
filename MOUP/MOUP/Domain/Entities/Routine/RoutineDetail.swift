//
//  RoutineDetail.swift
//  MOUP
//
//  Created by shinyoungkim on 11/6/25.
//

import Foundation

struct RoutineDetail {
    let routineId: Int
    let routineName: String
    let alarmTime: String?
    let tasks: [RoutineTaskItem]

    var summary: RoutineSummary {
        RoutineSummary(
            routineId: routineId,
            routineName: routineName,
            alarmTime: alarmTime
        )
    }
}
