//
//  UserService.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation
import Alamofire

protocol UserServiceProtocol: AnyObject {
    func fetchProfile() async throws -> UserProfileResponseDTO
    func updateNickname(_ nickname: String) async throws -> UpdateNicknameResponseDTO
    func deleteAccount() async throws -> DeleteAccountResponseDTO
}

final class UserService: UserServiceProtocol {
    private lazy var session = NetworkManager.shared.session
    
    func fetchProfile() async throws -> UserProfileResponseDTO {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let request = session.request(UserRouter.fetchProfile)
        let response = await request.serializingDecodable(UserProfileResponseDTO.self).response
        
        guard let statusCode = response.response?.statusCode else  {
            throw NetworkError.noResponse
        }
        
        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 401:
            print("프로필 조회 실패: 인증 실패")
            throw NetworkError.serverError
        case 404:
            print(AuthError.notMember.debugDescription!)
            throw AuthError.notMember
        case 409:
            print(AuthError.deletedUser.debugDescription!)
            throw AuthError.deletedUser
        default:
            print(NetworkError.serverError.debugDescription!)
            throw NetworkError.serverError
        }
    }
    
    func updateNickname(_ nickname: String) async throws -> UpdateNicknameResponseDTO {
        let requestDTO = UpdateNicknameRequestDTO(nickname: nickname)
        let request = session.request(UserRouter.updateNickname(requestDTO))
        let response = await request
            .serializingDecodable(UpdateNicknameResponseDTO.self)
            .response
        
        print("========== 닉네임 수정 ==========")
        print("statusCode: \(response.response?.statusCode ?? -1)")
        
        if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
            print("응답: \(jsonString)")
        }
        
        if let dto = response.value {
            print("✅ 닉네임 수정 성공: \(dto.nickname)")
        }
        print("================================")
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 400:
            print("잘못된 닉네임")
            throw NetworkError.serverError
        case 401:
            print("인증 실패")
            throw NetworkError.serverError
        case 404:
            print(AuthError.notMember.debugDescription!)
            throw AuthError.notMember
        case 409:
            print(AuthError.deletedUser.debugDescription!)
            throw AuthError.deletedUser
        default:
            print(NetworkError.serverError.debugDescription!)
            throw NetworkError.serverError
        }
    }
    
    func deleteAccount() async throws -> DeleteAccountResponseDTO {
        let request = session.request(UserRouter.deleteAccount)
        let response = await request.serializingDecodable(DeleteAccountResponseDTO.self).response
        
        print("========== 회원 탈퇴 ==========")
        print("statusCode: \(response.response?.statusCode ?? -1)")
        
        if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
            print("응답: \(jsonString)")
        }
        
        if let dto = response.value {
            print("✅ 회원 탈퇴 성공: userId \(dto.userId), deletedAt: \(dto.deletedAt)")
        }
        print("============================")
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 401:
            print("회원 탈퇴 실패: 인증 실패")
            throw NetworkError.serverError
        case 404:
            print(AuthError.notMember.debugDescription!)
            throw AuthError.notMember
        case 409:
            print(AuthError.deletedUser.debugDescription!)
            throw AuthError.deletedUser
        default:
            print(NetworkError.serverError.debugDescription!)
            throw NetworkError.serverError
        }
    }
}
