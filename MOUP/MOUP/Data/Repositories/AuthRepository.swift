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
        KeychainManager.shared.save(key: "accessToken", token: response.accessToken)
        KeychainManager.shared.save(key: "refreshToken", token: response.refreshToken)
        
        guard let role = response.role, !role.isEmpty else {
            throw AuthError.notMember
        }
        
        UserDefaultsManager.shared.userRole = role
    }
    
    func signUp(requestDTO: RegisterRequestDTO) async throws -> UserRole {
        let response = try await authService.signUp(requestDTO: requestDTO)
        let role: UserRole = response.role == "ROLE_WORKER" ? .worker : .owner
        return role
    }
}
