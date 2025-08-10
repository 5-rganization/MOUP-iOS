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
        guard let userId = response.userId else {
            throw NetworkError.noResponse // TODO: - userId가 에러 유무에 따라 옵셔널로 처리되기 때문에 없을 경우 어떤 에러로 표시해줄지 생각 해 봐야 함.
        }
        return UserIdentifier(userId: userId)
    }
}
