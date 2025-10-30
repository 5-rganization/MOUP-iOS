//
//  HomeOwnerSummary.swift
//  MOUP
//
//  Created by 송규섭 on 10/25/25.
//

import Foundation

struct HomeOwnerSummary {
    let month: Int
    let totalSalary: Int
    let prevMonthSalaryDiff: Int
    let todayRoutineCount: Int
    let workplaces: [OwnerMonthlyWorkplaceSummary]
}
