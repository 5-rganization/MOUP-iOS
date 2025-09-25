//
//  ManageAttendanceItem.swift
//  MOUP
//
//  Created by 송규섭 on 9/25/25.
//

import Foundation
import RxDataSources

struct AttendanceItem {
    var items: [Item]
}

extension AttendanceItem: SectionModelType {
    typealias Item = AttendanceData
    
    init(original: AttendanceItem, items: [AttendanceData]) {
        self = original
        self.items = items
    }
}
