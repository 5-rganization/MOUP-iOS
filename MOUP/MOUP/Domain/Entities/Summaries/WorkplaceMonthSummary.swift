//
//  WorkplaceMonthSummary.swift
//  MOUP
//
//  Created by 송규섭 on 10/25/25.
//

import Foundation
import Differentiator

/// Worker 기준 근무지에 관한 정보
struct WorkplaceMonthSummary {
    let workplace: WorkplaceSummary
    let salary: SalarySummary
    let totalWorkMinutes: Int
    let dayTimeMinutes: Int
    let nightTimeMinutes: Int
    let restTimeMinutes: Int
    let totalHolidayAllowance: Int
    let totalNightAllowance: Int
    let grossIncome: Int
    let nationalPension: Int
    let healthInsurance: Int
    let employmentInsurance: Int
    let incomeTax: Int
    let netIncome: Int
}

extension WorkplaceMonthSummary: IdentifiableType, Equatable {
    var identity: Int {
        return workplace.id
    }
    
    static func == (lhs: WorkplaceMonthSummary, rhs: WorkplaceMonthSummary) -> Bool {
        return lhs.workplace.id == rhs.workplace.id
    }
}
