//
//  GoogleAuthUseCase.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

final class GoogleAuthUseCase: GoogleAuthUseCaseProtocol {
    // MARK: - Properties
    private let googleAuthRepository: GoogleAuthRepositoryProtocol
    init(googleAuthRepository: GoogleAuthRepositoryProtocol) {
        self.googleAuthRepository = googleAuthRepository
    }

    // MARK: - Methods
    func signInWithGoogle(provider: String, providerId: String) async -> loginResponseEnum {
        return await googleAuthRepository.signInWithGoogle(provider: "LOGIN_GOOGLE", providerId: providerId)
    }
}
