//
//  GoogleAuthService.swift
//  MOUP
//
//  Created by 송규섭 on 7/27/25.
//

import Foundation
import Alamofire

protocol AuthServiceProtocol {
    func signIn(requestDTO: LoginRequestDTO) async throws -> LoginResponseDTO
    func signUp(requestDTO: RegisterRequestDTO) async throws -> RegisterResponseDTO
    func updateFCMToken(
        requestDTO: UpdateFCMTokenRequestDTO
    ) async throws -> UpdateFCMTokenResponseDTO
    func logout() async throws -> LogoutResponseDTO
}

final class AuthService: AuthServiceProtocol {
    private lazy var session = NetworkManager.shared.session
    
    func signIn(requestDTO: LoginRequestDTO) async throws -> LoginResponseDTO {
        let request = AF.request(AuthRouter.signIn(requestDTO))
        let response = await request.serializingDecodable(LoginResponseDTO.self).response

        print(response.value)
        print("statusCode: \(response.response?.statusCode)")

        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }

        switch statusCode {
        case 200, 201, 202:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        default:
            print(NetworkError.serverError.debugDescription!)
            throw NetworkError.serverError
        }
    }

    func signUp(requestDTO: RegisterRequestDTO) async throws -> RegisterResponseDTO {
        let request = session.request(AuthRouter.signUp(requestDTO))
        let response = await request.serializingDecodable(RegisterResponseDTO.self).response

        print(response.value)
        print("statusCode: \(response.response?.statusCode)")

        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }

        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 404:
            print(AuthError.notMember.debugDescription!)
            throw AuthError.notMember
        case 409:
            print(AuthError.alreadySignUp.debugDescription!)
            throw AuthError.alreadySignUp
        case 422:
            print(AuthError.invalidUserName.debugDescription!)
            throw AuthError.invalidUserName
        default:
            print(NetworkError.serverError.debugDescription!)
            throw NetworkError.serverError
        }
    }
    
    func updateFCMToken(
        requestDTO: UpdateFCMTokenRequestDTO
    ) async throws -> UpdateFCMTokenResponseDTO {
        let request = session.request(AuthRouter.updateFCMToken(requestDTO))
        let response = await request
            .serializingDecodable(UpdateFCMTokenResponseDTO.self)
            .response
        
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
            print("FCM 토큰 업데이트 실패: 인증 실패")
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
    
    func logout() async throws -> LogoutResponseDTO {
        let request = session.request(AuthRouter.logout)
        let response = await request.serializingDecodable(LogoutResponseDTO.self).response
        
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
            print("로그아웃 실패: 인증 실패")
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
