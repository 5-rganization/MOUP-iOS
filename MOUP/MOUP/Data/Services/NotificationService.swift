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
        
        print("========== 알림 목록 조회 ==========")
        print("statusCode: \(response.response?.statusCode ?? -1)")
        
        if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
            print("응답: \(jsonString)")
        }
        
        if let dtos = response.value {
            print("✅ 알림 \(dtos.count)개 조회 성공")
        }
        print("===================================")
        
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
        
        print("========== 알림 읽음 처리 ==========")
        print("statusCode: \(response.response?.statusCode ?? -1)")
        print("알림 ID: \(id)")
        print("===================================")
        
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
        
        print("========== 알림 모두 읽음 처리 ==========")
        print("statusCode: \(response.response?.statusCode ?? -1)")
        print("======================================")
        
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
        
        print("========== 알림 삭제 ==========")
        print("statusCode: \(response.response?.statusCode ?? -1)")
        print("알림 ID: \(id)")
        print("==============================")
        
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
        
        print("========== 알림 모두 삭제 ==========")
        print("statusCode: \(response.response?.statusCode ?? -1)")
        print("==================================")
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        guard statusCode == 200 else {
            throw NetworkError.serverError
        }
    }
}
