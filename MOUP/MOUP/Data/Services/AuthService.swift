//
//  GoogleAuthService.swift
//  MOUP
//
//  Created by 송규섭 on 7/27/25.
//

import Foundation
import Alamofire

protocol AuthServiceProtocol {
    func signInWithGoogle(requestDTO: SignInRequestDTO) async throws -> SignInResponseDTO
}

final class AuthService: AuthServiceProtocol {
    func signInWithGoogle(requestDTO: SignInRequestDTO) async throws -> SignInResponseDTO {
        let request = AF.request(AuthRouter.signIn(requestDTO))
        let response = await request.serializingDecodable(SignInResponseDTO.self).response

        print(response.value)
        print("statusCode: \(response.response?.statusCode)")

        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse // TODO: - 커스텀 에러를 좀 더 상세하게 나눌 필요가 있어보임.
        }

        print("signInWithGoogle - statusCode : \(statusCode)")

        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 404:
            print("404 - signInWithGoogle")
            throw AuthError.notMember
        default:
            print("500 or the other - signInWithGoogle")
            throw NetworkError.serverError
        }
    }
}
