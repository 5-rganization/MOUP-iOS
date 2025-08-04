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
    func signInWithGoogle(requestDTO: SignInRequestDTO) async -> LoginResponseEnum {
        return await googleAuthService.signInWithGoogle(requestDTO: requestDTO)
    }
}
