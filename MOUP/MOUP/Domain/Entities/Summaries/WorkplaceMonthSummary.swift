//
//  WorkplaceMonthSummary.swift
//  MOUP
//
//  Created by 송규섭 on 10/25/25.
//

import Foundation

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
