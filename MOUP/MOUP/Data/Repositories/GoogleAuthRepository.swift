//
//  GoogleAuthRepository.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

final class GoogleAuthRepository: GoogleAuthRepositoryProtocol {
    // MARK: - Properties
    private let googleAuthService: GoogleAuthServiceProtocol
    init(googleAuthService: GoogleAuthServiceProtocol) {
        self.googleAuthService = googleAuthService
    }

    // MARK: - Methods
    func signInWithGoogle(provider: String, providerId: String) async -> loginResponseEnum {
        return await googleAuthService.signInWithGoogle(provider: provider, providerId: providerId)
    }
}
