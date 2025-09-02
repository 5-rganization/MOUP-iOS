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
        let user = try await authRepository.signIn(requestDTO: requestDTO)

        UserDefaultsManager.shared.userId = user.userId
        // TODO: - Keychain에 jwt 저장 로직 필요
    }
}
