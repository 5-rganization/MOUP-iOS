//
//  Notification.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

struct UserNotification {
    let id: Int
    let senderId: Int?
    let receiverId: Int?
    let title: String
    let content: String
    let sentAt: Date
    let readAt: Date?
    
    var isRead: Bool {
        return readAt != nil
    }
}
