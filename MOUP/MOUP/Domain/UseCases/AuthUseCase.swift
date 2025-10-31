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
        try await authRepository.signIn(requestDTO: requestDTO)
    }

    func signUp(requestDTO: RegisterRequestDTO) async throws {
        let result = try await authRepository.signUp(requestDTO: requestDTO)

        UserDefaultsManager.shared.userRole = result.rawValue
    }
    
    func updateFCMToken(_ token: String) async throws {
        try await authRepository.updateFCMToken(token)
    }
}
