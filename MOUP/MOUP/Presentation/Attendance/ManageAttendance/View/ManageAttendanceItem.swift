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
    typealias Item = Employee
    
    init(original: ManageAttendanceItem, items: [Employee]) {
        self = original
        self.items = items
    }
}
