//
//  GoogleAuthRepositoryProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

protocol AuthRepositoryProtocol: AnyObject {
    func signIn(requestDTO: LoginRequestDTO) async throws
    func signUp(requestDTO: RegisterRequestDTO) async throws -> UserRole
    func renewAccessToken() async throws
}
