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
    func signInWithGoogle(requestDTO: SignInRequestDTO) async throws {
        let userIdentifier = try await googleAuthRepository.signInWithGoogle(requestDTO: requestDTO)

        UserDefaultsManager.shared.userId = userIdentifier.userId
    }
}
