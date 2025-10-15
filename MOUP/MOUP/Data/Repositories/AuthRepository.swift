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
    func signIn(requestDTO: LoginRequestDTO) async throws -> SignInResult {
        let response = try await authService.signIn(requestDTO: requestDTO)
        if let role = response.role, !role.isEmpty { // 회원 여부는 role이 제대로 저장되어있는지에 따라 분기됨.
            let user = User(
                userId: response.userId,
                role: UserRole(rawValue: role) ?? .worker,
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
            return .signIn(user)
        } else {
            return .needsSignUp(accessToken: response.accessToken, refreshToken: response.refreshToken)
        }
    }

    func signUp(requestDTO: RegisterRequestDTO) async throws -> UserRole {
        let response = try await authService.signUp(requestDTO: requestDTO)
        let role: UserRole = response.role == "ROLE_WORKER" ? .worker : .owner
        return role
    }
}
