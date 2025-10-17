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
}

final class AuthService: AuthServiceProtocol {
    private let session = NetworkManager.shared.session
    
    func signIn(requestDTO: LoginRequestDTO) async throws -> LoginResponseDTO {
        let request = AF.request(AuthRouter.signIn(requestDTO))
        let response = await request.serializingDecodable(LoginResponseDTO.self).response

        print(response.value)
        print("statusCode: \(response.response?.statusCode)")

        guard let statusCode = response.response?.statusCode,
              let dto = response.value else {
            throw NetworkError.noResponse
        }

        switch statusCode {
        case 200, 201, 202:
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
        case 400:
            print(AuthError.invalidUserName.debugDescription!)
            throw AuthError.invalidUserName
        default:
            print(NetworkError.serverError.debugDescription!)
            throw NetworkError.serverError
        }
    }
    
    
}
