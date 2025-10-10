//
//  AuthInterceptor.swift
//  MOUP
//
//  Created by 송규섭 on 10/10/25.
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let accessToken = KeychainManager.shared.read(key: "accessToken") {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(urlRequest))
    } // TODO: - 재발급, 만료 등 예외 처리 필요
}
