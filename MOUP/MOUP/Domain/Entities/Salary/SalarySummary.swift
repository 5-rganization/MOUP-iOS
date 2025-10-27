//
//  SalarySummary.swift
//  MOUP
//
//  Created by 송규섭 on 10/25/25.
//

import Foundation

struct SalarySummary {
    let type: SalaryType
    let calculation: SalaryCalculation
    let hourlyRate: Int?
    let fixedRate: Int?
    let salaryDate: Int?
    let salaryDay: String?
}
