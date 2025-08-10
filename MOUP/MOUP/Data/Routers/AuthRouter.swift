//
//  GoogleAuthRouter.swift
//  MOUP
//
//  Created by 송규섭 on 7/27/25.
//

import Foundation
import Alamofire

enum AuthRouter {
    case signIn(SignInRequestDTO)
}

extension AuthRouter: URLRequestConvertible {
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
        print("최종 url: \(url)")
        var request = try URLRequest(url: url, method: method)
        request = try encoding.encode(request, with: parameters)

        if let body = request.httpBody {
            print(String(data: body, encoding: .utf8))
        }

        return request
    }
}
