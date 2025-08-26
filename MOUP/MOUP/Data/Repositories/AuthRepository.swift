//
//  GoogleAuthRepository.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

final class AuthRepository: AuthRepositoryProtocol {
    // MARK: - Properties
    private let googleAuthService: AuthServiceProtocol
    init(googleAuthService: AuthServiceProtocol) {
        self.googleAuthService = googleAuthService
    }

    // MARK: - Methods
    func signInWithGoogle(requestDTO: SignInRequestDTO) async throws -> UserIdentifier {
        let response = try await googleAuthService.signInWithGoogle(requestDTO: requestDTO)
        let userId = response.userId
        return UserIdentifier(userId: userId)
    }
}
