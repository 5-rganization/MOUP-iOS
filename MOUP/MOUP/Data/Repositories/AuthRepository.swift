//
//  GoogleAuthRepository.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation
import os

final class AuthRepository: AuthRepositoryProtocol {
    // MARK: - Properties
    private let authService: AuthServiceProtocol
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "AuthRepository"
    )
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    // MARK: - Methods
    func signIn(requestDTO: LoginRequestDTO) async throws {
        let response = try await authService.signIn(requestDTO: requestDTO)
        KeychainManager.shared.save(key: "accessToken", token: response.accessToken)
        KeychainManager.shared.save(key: "refreshToken", token: response.refreshToken)
        
        guard let role = response.role, !role.isEmpty else {
            throw AuthError.notMember
        }
        
        UserDefaultsManager.shared.userRole = role
        UserDefaultsManager.shared.hasSignIn = true
    }
    
    func signUp(requestDTO: RegisterRequestDTO) async throws -> UserRole {
        let response = try await authService.signUp(requestDTO: requestDTO)
        let role: UserRole = response.role == "ROLE_WORKER" ? .worker : .owner
        UserDefaultsManager.shared.hasSignIn = true
        return role
    }
    
    func updateFCMToken(_ token: String) async throws {
        let requestDTO = UpdateFCMTokenRequestDTO(fcmToken: token)
        _ = try await authService.updateFCMToken(requestDTO: requestDTO)
    }
    
    func logout() async throws {
        _ = try await authService.logout()
        
        KeychainManager.shared.delete(key: "accessToken")
        KeychainManager.shared.delete(key: "refreshToken")
        
        UserDefaultsManager.shared.clearAllData()
        
        logger.info("로컬 데이터 정리 완료")
    }
}
