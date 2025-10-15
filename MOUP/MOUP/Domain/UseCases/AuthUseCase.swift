//
//  GoogleAuthUseCase.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

final class AuthUseCase: AuthUseCaseProtocol {
    // MARK: - Properties
    private let authRepository: AuthRepositoryProtocol
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    // MARK: - Methods
    func signIn(requestDTO: LoginRequestDTO) async throws {
        let result = try await authRepository.signIn(requestDTO: requestDTO)

        switch result {
        case .signIn(let user):
            UserDefaultsManager.shared.userId = user.userId
            UserDefaultsManager.shared.userRole = user.role.rawValue
            KeychainManager.shared.save(key: "accessToken", token: user.accessToken)
            KeychainManager.shared.save(key: "refreshToken", token: user.refreshToken)
        case .needsSignUp(let accessToken, let refreshToken):
            KeychainManager.shared.save(key: "accessToken", token: accessToken)
            KeychainManager.shared.save(key: "refreshToken", token: refreshToken)
            throw AuthError.notMember
        }
        
    }

    func signUp(requestDTO: RegisterRequestDTO) async throws {
        let result = try await authRepository.signUp(requestDTO: requestDTO)

        UserDefaultsManager.shared.userRole = result.rawValue
    }
}
