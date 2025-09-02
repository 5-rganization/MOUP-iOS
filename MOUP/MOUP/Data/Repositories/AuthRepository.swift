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
    func signIn(requestDTO: LoginRequestDTO) async throws -> User {
        let response = try await authService.signIn(requestDTO: requestDTO)
        let user = User(
            userId: response.userId,
            role: response.role == "ROLE_WORKER" ? .worker : .owner,
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        return user
    }

    func signUp(requestDTO: RegisterRequestDTO) async throws -> User {
        let response = try await authService.signUp(requestDTO: requestDTO)
        let user = User(
            userId: response.userId,
            role: response.role == "ROLE_WORKER" ? .worker : .owner,
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        return user
    }
}
