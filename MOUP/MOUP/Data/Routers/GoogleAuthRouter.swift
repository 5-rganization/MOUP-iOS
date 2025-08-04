//
//  GoogleAuthRouter.swift
//  MOUP
//
//  Created by 송규섭 on 7/27/25.
//

import Foundation
import Alamofire

enum GoogleAuthRouter {
    case signIn(provider: String, providerId: String)
}

extension GoogleAuthRouter: URLRequestConvertible {
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
        case .signIn(let provider, let providerId):
            return [
                "provider": provider,
                "providerId": providerId
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
