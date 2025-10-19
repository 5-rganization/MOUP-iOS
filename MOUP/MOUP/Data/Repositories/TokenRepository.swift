//
//  TokenRepository.swift
//  MOUP
//
//  Created by 송규섭 on 10/17/25.
//

import Foundation

final class TokenRepository: TokenRepositoryProtocol {
    private let tokenService: TokenServiceProtocol
    
    init(tokenService: TokenServiceProtocol) {
        self.tokenService = tokenService
    }
    
    func renewAccessToken() async throws {
        guard let requestToken = KeychainManager.shared.read(key: "refreshToken") else {
            throw AuthError.invalidToken
        }
        let requestDTO = RefreshTokenRequestDTO(refreshToken: requestToken)
        let response = try await tokenService.renewAccessToken(requestDTO: requestDTO)
        KeychainManager.shared.save(key: "accessToken", token: response.accessToken)
        KeychainManager.shared.save(key: "refreshToken", token: response.refreshToken)
    }
    
    func deleteTokens() {
        KeychainManager.shared.delete(key: "accessToken")
        KeychainManager.shared.delete(key: "refreshToken")
    }
    
    func checkSignedIn() -> Bool {
        let token = KeychainManager.shared.read(key: "accessToken")
        return token != nil
    }
    
    func fetchAccessToken() -> String? {
        KeychainManager.shared.read(key: "accessToken")
    }
    
    func fetchRefreshToken() -> String? {
        KeychainManager.shared.read(key: "refreshToken")
    }
}
