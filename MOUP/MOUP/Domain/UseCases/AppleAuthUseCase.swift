//
//  AppleAuthUseCase.swift
//  MOUP
//
//  Created by 서동환 on 8/8/25.
//

import Foundation

final class AppleAuthUseCase: AppleAuthUseCaseProtocol {
    // MARK: - Properties
    private let appleAuthRepository: AppleAuthRepositoryProtocol
    
    // MARK: - Initializer
    init(appleAuthRepository: AppleAuthRepositoryProtocol) {
        self.appleAuthRepository = appleAuthRepository
    }

    // MARK: - Methods
    func signInWithApple(requestDTO: SignInRequestDTO) async throws {
        let userIdentifier = try await appleAuthRepository.signInWithApple(requestDTO: requestDTO)

        UserDefaultsManager.shared.userId = userIdentifier.userId
    }
}
