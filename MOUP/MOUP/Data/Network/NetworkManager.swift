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
    let session: Session
    
    private init() {
        self.tokenService = TokenService()
        self.tokenRepository = TokenRepository(tokenService: tokenService)
        let interceptor = AuthInterceptor(tokenRepository: self.tokenRepository)
        self.session = Session(interceptor: interceptor)
    }
}
