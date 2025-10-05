//
//  RoutineItem.swift
//  MOUP
//
//  Created by 송규섭 on 10/5/25.
//

import Foundation
import RxDataSources

struct RoutineItem {
    var items: [Item]
}

extension RoutineItem: SectionModelType {
    typealias Item = Routine
    
    init(original: RoutineItem, items: [Routine]) {
        self = original
        self.items = items
    }
}
