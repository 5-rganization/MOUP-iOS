//
//  SalaryType.swift
//  MOUP
//
//  Created by 송규섭 on 10/25/25.
//

import Foundation

enum SalaryType: CaseIterable {
    case monthly
    case weekly
    case daily
    
    var displayText: String {
        switch self {
        case .monthly: return "매월"
        case .weekly: return "매주"
        case .daily: return "매일"
        }
    }
    
    var serverValue: String {
        switch self {
        case .monthly: return "SALARY_MONTHLY"
        case .weekly: return "SALARY_WEEKLY"
        case .daily: return "SALARY_DAILY"
        }
    }
    
    init?(displayText: String) {
        switch displayText {
        case "매월": self = .monthly
        case "매주": self = .weekly
        case "매일": self = .daily
        default: return nil
        }
    }
    
    init?(serverValue: String) {
        switch serverValue {
        case "SALARY_MONTHLY": self = .monthly
        case "SALARY_WEEKLY": self = .weekly
        case "SALARY_DAILY": self = .daily
        default: return nil
        }
    }
}
