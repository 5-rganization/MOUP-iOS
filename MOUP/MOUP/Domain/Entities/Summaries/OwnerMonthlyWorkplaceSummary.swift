//
//  OwnerMonthlyWorkplaceSummary.swift
//  MOUP
//
//  Created by 송규섭 on 10/25/25.
//

import Foundation
import Differentiator

/// Owner 기준 근무지에 관한 정보
struct OwnerMonthlyWorkplaceSummary {
    let workplace: WorkplaceSummary
    let workers: [MonthlyWorkerSummary]
}

extension OwnerMonthlyWorkplaceSummary: IdentifiableType, Equatable {
    var identity: Int {
        return workplace.id
    }
    
    static func == (lhs: OwnerMonthlyWorkplaceSummary, rhs: OwnerMonthlyWorkplaceSummary) -> Bool {
        return lhs.workplace.id == rhs.workplace.id
    }
}
