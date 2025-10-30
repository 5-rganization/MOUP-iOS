//
//  SalaryType.swift
//  MOUP
//
//  Created by 송규섭 on 10/25/25.
//

import Foundation

enum SalaryType: String {
    case monthly
    case weekly
    case daily
    
    init?(rawValue: String) {
        switch rawValue {
        case "SALARY_MONTHLY":
            self = .monthly
        case "SALARY_WEEKLY":
            self = .weekly
        case "SALARY_DAILY":
            self = .daily
        default:
            self = .monthly
        }
    }
}
