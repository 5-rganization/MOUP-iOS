//
//  UserRouter.swift
//  MOUP
//
//  Created by 신영 on 10/31/25.
//

import Foundation
import Alamofire

enum UserRouter {
    case fetchProfile
}

extension UserRouter: URLRequestConvertible {
    var baseURL: URL {
        guard let url = URL(string: NetworkConstants.baseURL) else {
            fatalError("Invalid base URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .fetchProfile:
            return "/users/profiles"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchProfile:
            return .get
        }
    }
    
    var requestBody: Encodable? {
        switch self {
        case .fetchProfile:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .fetchProfile:
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
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let httpBody = request.httpBody {
                print("Request body: \(String(data: httpBody, encoding: .utf8) ?? "")")
            }
        }
        
        return request
    }
}
