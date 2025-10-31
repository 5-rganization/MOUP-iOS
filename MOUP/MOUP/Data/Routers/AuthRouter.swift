//
//  GoogleAuthRouter.swift
//  MOUP
//
//  Created by 송규섭 on 7/27/25.
//

import Foundation
import Alamofire

enum AuthRouter {
    case signIn(LoginRequestDTO)
    case signUp(RegisterRequestDTO)
    case renewAccessToken(RefreshTokenRequestDTO)
    case updateFCMToken(UpdateFCMTokenRequestDTO)
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
        case .signUp:
            return "/auth/login/register"
        case .renewAccessToken:
            return "/auth/token/refresh"
        case .updateFCMToken:
            return "/users/fcm-token"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .signIn:
            return .post
        case .signUp:
            return .patch
        case .renewAccessToken:
            return .post
        case .updateFCMToken:
            return .patch
        }
    }

    var requestBody: Encodable? {
        switch self {
        case .signIn(let signInRequestDTO):
            return signInRequestDTO
        case .signUp(let signUpRequestDTO):
            return signUpRequestDTO
        case .renewAccessToken(let refreshAccessTokenRequestDTO):
            return refreshAccessTokenRequestDTO
        case .updateFCMToken(let updateFCMTokenRequestDTO):
            return updateFCMTokenRequestDTO
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .signIn, .signUp, .renewAccessToken, .updateFCMToken:
            return JSONEncoding.default
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
