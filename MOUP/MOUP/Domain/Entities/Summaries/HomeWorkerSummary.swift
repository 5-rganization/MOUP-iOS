//
//  HomeWorkerSummary.swift
//  MOUP
//
//  Created by 송규섭 on 10/25/25.
//

import Foundation

struct HomeWorkerSummary {
    let month: Int
    let totalSalary: Int
    let todayRoutineCount: Int
    let workplaces: [WorkplaceMonthSummary]
}
