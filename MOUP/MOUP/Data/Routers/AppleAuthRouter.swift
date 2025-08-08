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
}

extension AppleAuthRouter: URLRequestConvertible {
    var baseURL: URL {
        guard let url = URL(string: NetworkConstants.baseURL) else {
            fatalError("Invalid base URL")
        }
        return url
    }

    var path: String {
        switch self {
        case .signIn:
            return "/auth/login"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .signIn:
            return .post
        }
    }

    var parameters: Parameters? {
        switch self {
        case .signIn(let signInRequestDTO):
            return [
                "provider": signInRequestDTO.provider,
                "idToken": signInRequestDTO.idToken
            ]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .signIn:
            return JSONEncoding.default
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = try URLRequest(url: url, method: method)
        request = try encoding.encode(request, with: parameters)

        return request
    }
}
