//
//  AppleAuthRepositoryProtocol.swift
//  MOUP
//
//  Created by 서동환 on 8/8/25.
//

protocol AppleAuthRepositoryProtocol: AnyObject {
    func signInWithApple(requestDTO: SignInRequestDTO) async throws -> UserIdentifier
}
