//
//  AppleAuthUseCaseProtocol.swift
//  MOUP
//
//  Created by 서동환 on 8/8/25.
//

protocol AppleAuthUseCaseProtocol: AnyObject {
    func signIn(requestDTO: SignInRequestDTO) async throws
    func register(requestDTO: RegisterRequestDTO) async throws
}
