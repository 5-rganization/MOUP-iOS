//
//  GoogleAuthRepository.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    // MARK: - Properties
    private let authService: AuthServiceProtocol
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Methods
    func signIn(requestDTO: LoginRequestDTO) async throws {
        let response = try await authService.signIn(requestDTO: requestDTO)
        if let role = response.role, !role.isEmpty { // 회원 여부는 role이 제대로 저장되어있는지에 따라 분기됨.
            UserDefaultsManager.shared.userId = response.userId
            UserDefaultsManager.shared.userRole = role
            KeychainManager.shared.save(key: "accessToken", token: response.accessToken)
            KeychainManager.shared.save(key: "refreshToken", token: response.refreshToken)
        } else {
            KeychainManager.shared.save(key: "accessToken", token: response.accessToken)
            KeychainManager.shared.save(key: "refreshToken", token: response.refreshToken)
        }
    }

    func signUp(requestDTO: RegisterRequestDTO) async throws -> UserRole {
        let response = try await authService.signUp(requestDTO: requestDTO)
        let role: UserRole = response.role == "ROLE_WORKER" ? .worker : .owner
        return role
    }
    
    func renewAccessToken() async throws {
        guard let requestToken = KeychainManager.shared.read(key: "refreshToken") else {
            throw AuthError.invalidToken
        }
        let requestDTO = RefreshTokenRequestDTO(refreshToken: requestToken)
        let response = try await authService.renewAccessToken(requestDTO: requestDTO)
        KeychainManager.shared.save(key: "accessToken", token: response.accessToken)
        KeychainManager.shared.save(key: "refreshToken", token: response.refreshToken)
    }
}
