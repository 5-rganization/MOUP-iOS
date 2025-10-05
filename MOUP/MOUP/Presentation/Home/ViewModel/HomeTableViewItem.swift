//
//  HomeTableViewFirstSection.swift
//  MOUP
//
//  Created by 송규섭 on 8/12/25.
//

import Foundation
import RxDataSources

enum HomeSectionItem: Equatable, IdentifiableType {
    case worker(WorkerWorkplaceCellInfo)
    case owner(OwnerWorkplaceCellInfo)

    var identity: String {
        switch self {
        case .worker(let info):
            return info.identity
        case .owner(let info):
            return info.identity
        }
    }
}

struct HomeTableViewFirstSection {
    let identity: Int
    var header: String
    var items: [Item]
}

extension HomeTableViewFirstSection: AnimatableSectionModelType {
    typealias Item = HomeSectionItem
    typealias Identity = Int

    init(original: HomeTableViewFirstSection, items: [Item]) {
        self = original
        self.items = items
    }
}
