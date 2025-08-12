//
//  WorkerWorkplaceCellInfo.swift
//  MOUP
//
//  Created by 송규섭 on 8/12/25.
//

import Foundation
import Differentiator

struct WorkerWorkplaceCellInfo {
    let workplace: WorkplaceData
}

extension WorkerWorkplaceCellInfo: IdentifiableType, Equatable  {
    var identity: String {
        return workplace.id
    }

    static func == (lhs: WorkerWorkplaceCellInfo, rhs: WorkerWorkplaceCellInfo) -> Bool {
        return lhs.workplace.id == rhs.workplace.id
    }
}
