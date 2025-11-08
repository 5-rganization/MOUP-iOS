//
//  NotificationUseCaseProtocol.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

protocol NotificationUseCaseProtocol: AnyObject {
    func fetchNotifications() async throws -> [UserNotification]
    func markAsRead(id: Int) async throws
    func markAllAsRead() async throws
    func deleteNotification(id: Int) async throws
    func deleteAllNotifications() async throws
}
