//
//  UserUseCase.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

final class UserUseCase: UserUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func fetchProfile() async throws -> UserProfile {
        try await userRepository.fetchProfile()
    }
    
    func updateNickname(_ nickname: String) async throws -> String {
        try await userRepository.updateNickname(nickname)
    }
    
    func deleteAccount() async throws {
        try await userRepository.deleteAccount()
    }
}
