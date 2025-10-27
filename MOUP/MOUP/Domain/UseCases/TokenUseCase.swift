//
//  TokenUseCase.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation

final class TokenUseCase: TokenUseCaseProtocol {
    private let tokenRepository: TokenRepositoryProtocol
    
    init(tokenRepository: TokenRepositoryProtocol) {
        self.tokenRepository = tokenRepository
    }
    
    func renewAccessToken() async throws {
        try await tokenRepository.renewAccessToken()
    }
    
    func deleteTokens() {
        tokenRepository.deleteTokens()
    }
    
    func checkSignedIn() -> Bool {
        tokenRepository.checkSignedIn()
    }
    
    func fetchAccessToken() -> String? {
        tokenRepository.fetchAccessToken()
    }
    
    func fetchRefreshToken() -> String? {
        tokenRepository.fetchRefreshToken()
    }
}
