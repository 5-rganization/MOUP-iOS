//
//  NotificationRepository.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

final class NotificationRepository: NotificationRepositoryProtocol {
    private let notificationService: NotificationServiceProtocol
    
    init(notificationService: NotificationServiceProtocol) {
        self.notificationService = notificationService
    }
    
//    func fetchNotifications() async throws -> [UserNotification] {
//        let dtos = try await notificationService.fetchNotifications()
//        return dtos.map { mapToEntity($0) }
//    }
    func fetchNotifications() async throws -> [UserNotification] {
        let response = try await notificationService.fetchNotifications()
        return response.notificationList.map { $0.toDomain() }
    }
    
    func markAsRead(id: Int) async throws {
        try await notificationService.markAsRead(id: id)
    }
    
    func markAllAsRead() async throws {
        try await notificationService.markAllAsRead()
    }
    
    func deleteNotification(id: Int) async throws {
        try await notificationService.deleteNotification(id: id)
    }
    
    func deleteAllNotifications() async throws {
        try await notificationService.deleteAllNotifications()
    }
    
//    private func mapToEntity(_ dto: NotificationResponseDTO) -> UserNotification {
//        let sentDate = parseDate(dto.sentAt)
//        let readDate = dto.readAt.flatMap { parseDate($0) }
//        
//        return UserNotification(
//            id: dto.id,
//            senderId: dto.senderId,
//            receiverId: dto.receiverId,
//            title: dto.title,
//            content: dto.content,
//            sentAt: sentDate,
//            readAt: readDate
//        )
//    }
//    
//    private func parseDate(_ dateString: String) -> Date {
//        let formats = [
//            "yyyy-MM-dd'T'HH:mm:ss",
//            "yyyy-MM-dd'T'HH:mm:ss.SSS",
//            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
//        ]
//        
//        for format in formats {
//            let formatter = DateFormatter()
//            formatter.dateFormat = format
//            formatter.timeZone = TimeZone(identifier: "UTC")
//            
//            if let date = formatter.date(from: dateString) {
//                return date
//            }
//        }
//        
//        return Date()
//    }
}
