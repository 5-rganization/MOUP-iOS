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
    
    let type: PushNotificationType?
    let metadata: NotificationMetadata?
    
    var isRead: Bool {
        return readAt != nil
    }
}

struct NotificationMetadata {
    let type: PushNotificationType?
    let workerId: Int?
    let workplaceId: Int?
    
    init(
        type: PushNotificationType? = nil,
        workerId: Int? = nil,
        workplaceId: Int? = nil
    ) {
        self.type = type
        self.workerId = workerId
        self.workplaceId = workplaceId
    }
}
