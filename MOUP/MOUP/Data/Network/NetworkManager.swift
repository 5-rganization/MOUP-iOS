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
    
    let session: Session
    
    init(session: Session) {
        self.session = session
    }
    
    static func configure(tokenUseCase: TokenUseCaseProtocol) {
        let interceptor = AuthInterceptor(tokenUseCase: tokenUseCase)
        let session = Session(interceptor: interceptor)
        shared = NetworkManager(session: session)
    }
}
