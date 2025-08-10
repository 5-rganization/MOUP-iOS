//
//  GoogleAuthUseCase.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

final class AuthUseCase: AuthUseCaseProtocol {
    // MARK: - Properties
    private let googleAuthRepository: AuthRepositoryProtocol
    init(googleAuthRepository: AuthRepositoryProtocol) {
        self.googleAuthRepository = googleAuthRepository
    }

    // MARK: - Methods
    func signInWithGoogle(requestDTO: SignInRequestDTO) async throws {
        let userIdentifier = try await googleAuthRepository.signInWithGoogle(requestDTO: requestDTO)

        UserDefaultsManager.shared.userId = userIdentifier.userId
    }
}
