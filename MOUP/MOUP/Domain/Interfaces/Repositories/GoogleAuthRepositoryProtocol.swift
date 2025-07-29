//
//  GoogleAuthRepositoryProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

protocol GoogleAuthRepositoryProtocol: AnyObject {
    func signInWithGoogle(provider: String, providerId: String) async -> loginResponseEnum
}
