//
//  FCMTokenManager.swift
//  MOUP
//
//  Created by 신영 on 10/31/25.
//

import Foundation
import os

final class FCMTokenManager {
    static let shared = FCMTokenManager()
    private init() {}
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "FCMTokenManager"
    )
    private var authUseCase: AuthUseCaseProtocol?
    
    func configure(authUseCase: AuthUseCaseProtocol) {
        self.authUseCase = authUseCase
    }
    
    func syncTokenToServer() {
        guard let token = UserDefaultsManager.shared.fcmToken else {
            logger.warning("FCM 토큰이 없어 서버 동기화를 건너뜁니다.")
            return
        }
        
        guard let authUseCase = authUseCase else {
            logger.warning("AuthUseCase가 설정되지 않아 FCM 토큰 동기화를 건너뜁니다.")
            return
        }
        
        Task {
            do {
                try await authUseCase.updateFCMToken(token)
                logger.info("FCM 토큰 서버 동기화 성공")
            } catch {
                logger.error("FCM 토큰 서버 동기화 실패: \(error.localizedDescription)")
                // MARK: - TODO: 재시도 로직 추가 고려
            }
        }
    }
}
