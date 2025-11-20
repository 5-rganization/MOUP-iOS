//
//  NotificationResponseDTOs.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

struct NotificationListResponseDTO: Decodable {
    let notificationList: [NotificationItemDTO]
}

struct NotificationItemDTO: Decodable {
    let id: Int
    let senderId: Int?
    let receiverId: Int?
    let title: String
    let content: String
    let sentAt: String
    let readAt: String?
    
    let type: String?
    let workerId: Int?
    let workplaceId: Int?
    
    func toDomain() -> UserNotification {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")

        let sentDate = dateFormatter.date(from: sentAt) ?? Date()
        let readDate = readAt.flatMap { readAtString in
            dateFormatter.date(from: readAtString)
        }
        
        let notificationType = PushNotificationType(from: type)
        
        let metadata: NotificationMetadata?
        if workerId != nil || workplaceId != nil {
            metadata = NotificationMetadata(
                workerId: workerId,
                workplaceId: workplaceId
            )
        } else {
            metadata = nil
        }
        
        return UserNotification(
            id: id,
            senderId: senderId,
            receiverId: receiverId,
            title: title,
            content: content,
            sentAt: sentDate,
            readAt: readDate,
            type: notificationType,
            metadata: metadata
        )
    }
}
