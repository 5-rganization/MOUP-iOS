//
//  AppleAuthRouter.swift
//  MOUP
//
//  Created by 서동환 on 8/8/25.
//

import Foundation

import Alamofire

enum AppleAuthRouter {
    case signIn(SignInRequestDTO)
    case register(RegisterRequestDTO)
}

extension AppleAuthRouter: URLRequestConvertible {
    var baseURL: URL {
        guard let url = URL(string: NetworkConstants.baseURL) else {
            fatalError("Invalid base URL")
        }
        return url
    }

    var path: String {
        let basePath = "/auth"
        switch self {
        case .signIn:
            return basePath + "/login"
        case .register:
            return basePath + "/register"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .signIn, .register:
            return .post
        }
    }
    
    var body: Encodable {
        switch self {
        case .signIn(let dto):
            return dto
        case .register(let dto):
            return dto
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = try URLRequest(url: url, method: method)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        return request
    }
}
