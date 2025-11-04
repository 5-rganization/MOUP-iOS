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
    typealias Item = AttendanceInfo
    
    init(original: AttendanceItem, items: [AttendanceInfo]) {
        self = original
        self.items = items
    }
}
