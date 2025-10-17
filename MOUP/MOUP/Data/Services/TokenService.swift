//
//  TokenService.swift
//  MOUP
//
//  Created by 송규섭 on 10/17/25.
//

import Foundation
import Alamofire

protocol TokenServiceProtocol: AnyObject {
    func renewAccessToken(requestDTO: RefreshTokenRequestDTO) async throws -> RefreshTokenResponseDTO
}

final class TokenService: TokenServiceProtocol {
    func renewAccessToken(requestDTO: RefreshTokenRequestDTO) async throws -> RefreshTokenResponseDTO {
        let request = AF.request(AuthRouter.renewAccessToken(requestDTO))
        let response = await request.serializingDecodable(RefreshTokenResponseDTO.self).response
        
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
            print(AuthError.invalidToken.debugDescription!)
            throw AuthError.invalidToken
        case 409:
            print(AuthError.deletedUser.debugDescription!)
            throw AuthError.deletedUser
        default:
            print(NetworkError.serverError.debugDescription!)
            throw NetworkError.serverError
        }
    }
}
