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
}
