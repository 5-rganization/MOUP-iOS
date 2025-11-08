//
//  NotificationService.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation
import Alamofire

protocol NotificationServiceProtocol: AnyObject {
    func fetchNotifications() async throws -> [NotificationResponseDTO]
    func markAsRead(id: Int) async throws
    func markAllAsRead() async throws
    func deleteNotification(id: Int) async throws
    func deleteAllNotifications() async throws
}

final class NotificationService: NotificationServiceProtocol {
    private lazy var session = NetworkManager.shared.session
    
    func fetchNotifications() async throws -> [NotificationResponseDTO] {
        let request = session.request(NotificationRouter.fetchNotifications)
        let response = await request.serializingDecodable([NotificationResponseDTO].self).response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        switch statusCode {
        case 200:
            guard let dtos = response.value else {
                throw NetworkError.noResponse
            }
            return dtos
        case 401:
            print("알림 조회 실패: 인증 실패")
            throw NetworkError.serverError
        case 404:
            print("알림 조회 실패: 조회 결과 없음")
            return []
        default:
            print(NetworkError.serverError.debugDescription!)
            throw NetworkError.serverError
        }
    }
    
    func markAsRead(id: Int) async throws {
        let request = session.request(NotificationRouter.markAsRead(id: id))
        let response = await request.serializingData().response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        guard statusCode == 200 else {
            throw NetworkError.serverError
        }
    }
    
    func markAllAsRead() async throws {
        let request = session.request(NotificationRouter.markAllAsRead)
        let response = await request.serializingData().response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        guard statusCode == 200 else {
            throw NetworkError.serverError
        }
    }
    
    func deleteNotification(id: Int) async throws {
        let request = session.request(NotificationRouter.deleteNotification(id: id))
        let response = await request.serializingData().response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        guard statusCode == 200 else {
            throw NetworkError.serverError
        }
    }
    
    func deleteAllNotifications() async throws {
        let request = session.request(NotificationRouter.deleteAllNotifications)
        let response = await request.serializingData().response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        guard statusCode == 200 else {
            throw NetworkError.serverError
        }
    }
}
