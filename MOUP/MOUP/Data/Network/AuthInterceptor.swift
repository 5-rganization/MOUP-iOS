//
//  AuthInterceptor.swift
//  MOUP
//
//  Created by 송규섭 on 10/10/25.
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {
    private let tokenUseCase: TokenUseCaseProtocol // TODO: - thread safety 추가 후 sendable 채택 필요
    
    init(tokenUseCase: TokenUseCaseProtocol) {
        self.tokenUseCase = tokenUseCase
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let accessToken = tokenUseCase.fetchAccessToken() {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetryWithError(error)) // TODO: - 로그인 Coordinator로 전환
            return
        }
        
        // TODO: - 재발급 요청
        Task {
            do {
                try await tokenUseCase.renewAccessToken() // 액세스 토큰 재발급
                completion(.retry)
            } catch {
                completion(.doNotRetryWithError(error))
                
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .unauthorizedAccessDetected,
                        object: nil
                    )
                }
            }
        }
    }
}
