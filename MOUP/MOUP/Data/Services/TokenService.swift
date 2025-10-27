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
        // 토큰을 재발급 받기 위함이므로 Bearer 내 토큰 추가하지 않고 DTO에 추가하는 방식으로 진행. 따라서 기본값을 가지는 AF.request 사용
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
