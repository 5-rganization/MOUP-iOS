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
    let session: Session
    
    private init() {
        let interceptor = AuthInterceptor()
        session = Session(interceptor: interceptor)
    }
}
