//
//  AuthInterceptor.swift
//  MOUP
//
//  Created by 송규섭 on 10/10/25.
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {
    // MARK: - Properties
    private let tokenUseCase: TokenUseCaseProtocol // TODO: - thread safety 추가 후 sendable 채택 필요
    private let lock = NSLock() // 동시성 제어용 락
    private var isRefreshing = false // 현재 재발급 중인지
    
    private typealias RetryHandler = (RetryResult) -> Void
    private var retryHandlers: [RetryHandler] = [] // 재발급 완료 후 처리할 completion 모음
    
    enum AuthInterceptorError: Error {
        case tokenRefreshFailed
    }
    
    // MARK: - Initializer
    init(tokenUseCase: TokenUseCaseProtocol) {
        self.tokenUseCase = tokenUseCase
    }
    
    // MARK: - Adapt
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var urlRequest = urlRequest
        
        if let accessToken = tokenUseCase.fetchAccessToken() {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(urlRequest))
    }
    
    // MARK: - Retry
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetryWithError(error)) // TODO: - 로그인 Coordinator로 전환
            return
        }
        
        lock.lock() // 현재 스레드가 점유
        
        retryHandlers.append(completion) // 재발급 이후 동작 정의
        
        if isRefreshing { // 발급 중일 경우 점유 해제 및 처리 종료
            lock.unlock()
            return
        }
        
        // 재발급 중인 스레드가 없을 경우, 해당 스레드가 리더가 되어 재발급 시작
        isRefreshing = true
        lock.unlock()
        
        refreshTokens()
        
        // TODO: - 재발급 요청
        
    }
    
    private func refreshTokens() {
        Task {
            let success: Bool
            
            do {
                try await tokenUseCase.renewAccessToken() // 액세스 토큰 재발급
                success = true
            } catch {
                success = false
                
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .unauthorizedAccessDetected,
                        object: nil
                    )
                }
            }
            
            finishRefreshing(success: success)
        }
    }
    
    private func finishRefreshing(success: Bool) {
        // 락 설정 후 큐 상태 복사 후 초기화
        lock.lock()
        let handlers = retryHandlers
        retryHandlers.removeAll()
        isRefreshing = false
        lock.unlock()
        
        // 락을 풀고 나서 completion 호출
        if success { // 재발급 성공, 다시 요청 시도
            handlers.forEach { $0(.retry) }
        } else { // 재발급 실패, 모두 실패 처리
            let error = AuthInterceptorError.tokenRefreshFailed
            handlers.forEach { $0(.doNotRetryWithError(error)) }
        }
    }
}
