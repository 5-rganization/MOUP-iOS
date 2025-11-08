//
//  SalaryCalculation.swift
//  MOUP
//
//  Created by 서동환 on 8/17/25.
//

/// 급여 유형 Enum
/// - `hourly`: 시급
/// - `fixed`: 고정급
enum SalaryCalculation: String {
    case hourly = "SALARY_CALCULATION_HOURLY"
    case fixed = "SALARY_CALCULATION_FIXED"
    
    var displayStr: String {
        switch self {
        case .hourly: "시급"
        case .fixed: "고정급"
        }
    }
}
