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
}

final class UserService: UserServiceProtocol {
    private lazy var session = NetworkManager.shared.session
    
    func fetchProfile() async throws -> UserProfileResponseDTO {
        let request = session.request(UserRouter.fetchProfile)
        let response = await request.serializingDecodable(UserProfileResponseDTO.self).response
        
//        print(response.value)
//        print("statusCode: \(response.response?.statusCode)")
        
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
}
