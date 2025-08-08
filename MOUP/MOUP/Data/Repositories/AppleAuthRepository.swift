//
//  AppleAuthRepository.swift
//  MOUP
//
//  Created by 서동환 on 8/8/25.
//

final class AppleAuthRepository: AppleAuthRepositoryProtocol {
    // MARK: - Properties
    private let appleAuthService: AppleAuthServiceProtocol
    
    // MARK: - Initializer
    init(appleAuthService: AppleAuthServiceProtocol) {
        self.appleAuthService = appleAuthService
    }

    // MARK: - Internal Methods
    func signInWithApple(requestDTO: SignInRequestDTO) async throws -> UserIdentifier {
        let response = try await appleAuthService.signInWithApple(requestDTO: requestDTO)
        guard let userId = response.userId else {
            throw NetworkError.noResponse
        }
        return UserIdentifier(userId: userId)
    }
}
