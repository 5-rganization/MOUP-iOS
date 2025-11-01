//
//  UserRepository.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

final class UserRepository: UserRepositoryProtocol {
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol) {
        self.userService = userService
    }
    
    func fetchProfile() async throws -> UserProfile {
        let dto = try await userService.fetchProfile()
        return mapToEntity(dto)
    }
    
    private func mapToEntity(_ dto: UserProfileResponseDTO) -> UserProfile {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdDate = dateFormatter.date(from: dto.createdAt) ?? Date()
        
        let role: UserRole = dto.role == "ROLE_WORKER" ? .worker : .owner
        
        return UserProfile(
            userId: dto.userId,
            username: dto.username,
            nickname: dto.nickname,
            profileImageURL: dto.profileImg,
            role: role,
            createdAt: createdDate
        )
    }
    
    func updateNickname(_ nickname: String) async throws -> String {
        let dto = try await userService.updateNickname(nickname)
        return dto.nickname
    }
}
