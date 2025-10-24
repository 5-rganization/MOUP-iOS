//
//  NetworkManager.swift
//  MOUP
//
//  Created by 송규섭 on 10/10/25.
//

import Foundation
import Alamofire

final class NetworkManager {
    static private(set) var shared: NetworkManager!
    
    private let tokenUseCase: TokenUseCaseProtocol
    let session: Session
    
    init(tokenUseCase: TokenUseCaseProtocol) {
        self.tokenUseCase = tokenUseCase
        let interceptor = AuthInterceptor(tokenUseCase: tokenUseCase)
        self.session = Session(interceptor: interceptor)
    }
    
    static func configure(tokenUseCase: TokenUseCaseProtocol) {
        shared = NetworkManager(tokenUseCase: tokenUseCase)
    }
}
