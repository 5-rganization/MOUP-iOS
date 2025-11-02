//
//  NotificationRouter.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation
import Alamofire

enum NotificationRouter {
    case fetchNotifications
    case fetchNotification(id: Int)
    case markAsRead(id: Int)
    case markAllAsRead
    case deleteNotification(id: Int)
    case deleteAllNotifications
}

extension NotificationRouter: URLRequestConvertible {
    var baseURL: URL {
        guard let url = URL(string: NetworkConstants.baseURL) else {
            fatalError("Invalid base URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .fetchNotifications:
            return "/alarms/notifications"
        case .fetchNotification(let id):
            return "/alarms/notifications/\(id)"
        case .markAsRead(let id):
            return "/alarms/notifications/\(id)/read"
        case .markAllAsRead:
            return "/alarms/notifications/read"
        case .deleteNotification(let id):
            return "/alarms/notifications/\(id)"
        case .deleteAllNotifications:
            return "/alarms/notifications"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchNotifications, .fetchNotification:
            return .get
        case .markAsRead, .markAllAsRead:
            return .patch
        case .deleteNotification, .deleteAllNotifications:
            return .delete
        }
    }
    
    var requestBody: Encodable? {
        switch self {
        default:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        default:
            return URLEncoding.default
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        print("최종 url: \(url)")
        var request = try URLRequest(url: url, method: method)
        
        if let body = requestBody {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            
            if let httpBody = request.httpBody {
                print("Request body: \(String(data: httpBody, encoding: .utf8) ?? "")")
            }
        }
        
        return request
    }
}
