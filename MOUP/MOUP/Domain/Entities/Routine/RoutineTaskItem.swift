//
//  RoutineTaskItem.swift
//  MOUP
//
//  Created by 신영 on 11/5/25.
//

import Foundation

struct RoutineTaskItem: Hashable {
    let id: UUID
    var content: String
    var orderIndex: Int

    init(content: String, orderIndex: Int, id: UUID = UUID()) {
        self.id = id
        self.content = content
        self.orderIndex = orderIndex
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: RoutineTaskItem, rhs: RoutineTaskItem) -> Bool {
        return lhs.id == rhs.id
    }

    func toDTO() -> RoutineTaskDTO {
        return RoutineTaskDTO(content: content, orderIndex: orderIndex)
    }
}

extension RoutineTaskItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case orderIndex
    }
}
