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

    // MARK: - signIn
    func signIn(requestDTO: SignInRequestDTO) async throws {
        let userIdentifier = try await appleAuthRepository.signIn(requestDTO: requestDTO)
        UserDefaultsManager.shared.userId = userIdentifier.userId
    }
    
    // MARK: - register
    func register(requestDTO: RegisterRequestDTO) async throws {
        let userIdentifier = try await appleAuthRepository.register(requestDTO: requestDTO)
        UserDefaultsManager.shared.userId = userIdentifier.userId
    }
}
