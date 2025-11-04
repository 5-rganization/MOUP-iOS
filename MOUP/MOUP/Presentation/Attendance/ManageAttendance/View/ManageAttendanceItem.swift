//
//  ManageAttendanceItem.swift
//  MOUP
//
//  Created by 송규섭 on 9/26/25.
//

import Foundation
import RxDataSources

struct ManageAttendanceItem {
    var items: [Item]
}

extension ManageAttendanceItem: SectionModelType {
    typealias Item = WorkerSummary
    
    init(original: ManageAttendanceItem, items: [WorkerSummary]) {
        self = original
        self.items = items
    }
}
