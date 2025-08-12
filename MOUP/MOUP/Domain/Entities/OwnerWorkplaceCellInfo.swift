//
//  OwnerWorkplaceCellInfo.swift
//  MOUP
//
//  Created by 송규섭 on 8/12/25.
//

import Foundation
import Differentiator

struct OwnerWorkplaceCellInfo {
    let workplace: WorkplaceData
}

extension OwnerWorkplaceCellInfo: IdentifiableType, Equatable {
    var identity: String {
        return workplace.id
    }

    static func == (lhs: OwnerWorkplaceCellInfo, rhs: OwnerWorkplaceCellInfo) -> Bool {
        return lhs.workplace.id == rhs.workplace.id
    }
}
