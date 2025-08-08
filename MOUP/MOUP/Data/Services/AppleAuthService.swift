//
//  AppleAuthService.swift
//  MOUP
//
//  Created by 서동환 on 8/8/25.
//

import Alamofire

protocol AppleAuthServiceProtocol: AnyObject {
    func signInWithApple(requestDTO: SignInRequestDTO) async throws -> SignInResponseDTO
}

final class AppleAuthService: AppleAuthServiceProtocol {
    func signInWithApple(requestDTO: SignInRequestDTO) async throws -> SignInResponseDTO {
        let request = AF.request(AppleAuthRouter.signIn(requestDTO))
        let response = await request.serializingDecodable(SignInResponseDTO.self).response
        
        if let error = response.error {
            throw NetworkError.invalidResponse(error)
        }

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
            throw AuthError.notMember
        default:
            throw NetworkError.serverError
        }
    }
}
