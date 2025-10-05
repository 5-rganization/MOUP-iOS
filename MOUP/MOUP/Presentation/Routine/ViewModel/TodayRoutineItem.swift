//
//  TodayRoutineItem.swift
//  MOUP
//
//  Created by 송규섭 on 10/5/25.
//

import Foundation
import RxDataSources

struct TodayRoutineItem {
    var items: [Item]
}

extension TodayRoutineItem: SectionModelType {
    typealias Item = TodayRoutine
    
    init(original: TodayRoutineItem, items: [TodayRoutine]) {
        self = original
        self.items = items
    }
}
