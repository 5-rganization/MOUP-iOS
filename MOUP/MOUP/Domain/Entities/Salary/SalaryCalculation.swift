//
//  SalaryCalculation.swift
//  MOUP
//
//  Created by 서동환 on 8/17/25.
//

/// 급여 유형 Enum
/// - `hourly`: 시급
/// - `fixed`: 고정급
enum SalaryCalculation {
    case hourly
    case fixed
    
    var serverValue: String {
        switch self {
        case .hourly: return "SALARY_CALCULATION_HOURLY"
        case .fixed:  return "SALARY_CALCULATION_FIXED"
        }
    }
    
    var displayStr: String {
        switch self {
        case .hourly: return "시급"
        case .fixed:  return "고정급"
        }
    }

    /// UI에서 선택한 문자열("시급", "고정급") → ENUM 변환
    init?(displayStr: String) {
        switch displayStr {
        case "시급": self = .hourly
        case "고정급": self = .fixed
        default: return nil
        }
    }
    
    init?(serverValue: String) {
        switch serverValue {
        case "SALARY_CALCULATION_HOURLY": self = .hourly
        case "SALARY_CALCULATION_FIXED": self = .fixed
        default: return nil
        }
    }
}
