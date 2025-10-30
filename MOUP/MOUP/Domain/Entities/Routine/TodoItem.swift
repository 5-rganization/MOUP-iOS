//
//  TodoItem.swift
//  MOUP
//
//  Created by 송규섭 on 10/6/25.
//

import Foundation

struct TodoItem: Hashable, Codable {
    let id: UUID
    var text: String
    
    init(text: String) {
        self.id = UUID()
        self.text = text
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.id == rhs.id
    }
}
