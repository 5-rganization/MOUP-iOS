//
//  SalarySummary.swift
//  MOUP
//
//  Created by 송규섭 on 10/25/25.
//

import Foundation

struct SalarySummary { // TODO: - 후에 필요 없을 시 제거 필요
    let type: SalaryType
    let calculation: SalaryCalculation
    let hourlyRate: Int?
    let fixedRate: Int?
    let salaryDate: Int? // 급여일 (일 단위)
    let salaryDay: String? // 급여일 (요일 단위)
}
