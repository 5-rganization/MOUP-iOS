//
//  NotificationUseCase.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

final class NotificationUseCase: NotificationUseCaseProtocol {
    private let notificationRepository: NotificationRepositoryProtocol
    
    init(notificationRepository: NotificationRepositoryProtocol) {
        self.notificationRepository = notificationRepository
    }
    
    func fetchNotifications() async throws -> [UserNotification] {
        try await notificationRepository.fetchNotifications()
    }
    
    func markAsRead(id: Int) async throws {
        try await notificationRepository.markAsRead(id: id)
    }
    
    func markAllAsRead() async throws {
        try await notificationRepository.markAllAsRead()
    }
    
    func deleteNotification(id: Int) async throws {
        try await notificationRepository.deleteNotification(id: id)
    }
    
    func deleteAllNotifications() async throws {
        try await notificationRepository.deleteAllNotifications()
    }
}
