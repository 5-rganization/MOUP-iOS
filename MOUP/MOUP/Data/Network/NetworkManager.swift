//
//  NetworkManager.swift
//  MOUP
//
//  Created by 송규섭 on 10/10/25.
//

import Foundation
import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    private let tokenService: TokenServiceProtocol
    private let tokenRepository: TokenRepositoryProtocol
    private let tokenUseCase: TokenUseCaseProtocol
    let session: Session
    
    private init() {
        self.tokenService = TokenService()
        self.tokenRepository = TokenRepository(tokenService: tokenService)
        self.tokenUseCase = TokenUseCase(tokenRepository: tokenRepository)
        let interceptor = AuthInterceptor(tokenUseCase: tokenUseCase)
        self.session = Session(interceptor: interceptor)
    }
}
