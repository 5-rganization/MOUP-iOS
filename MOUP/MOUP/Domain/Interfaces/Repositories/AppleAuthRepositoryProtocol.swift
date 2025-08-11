//
//  AppleAuthRepositoryProtocol.swift
//  MOUP
//
//  Created by 서동환 on 8/8/25.
//

protocol AppleAuthRepositoryProtocol: AnyObject {
    func signIn(requestDTO: SignInRequestDTO) async throws -> UserIdentifier
    func register(requestDTO: RegisterRequestDTO) async throws -> UserIdentifier
}
