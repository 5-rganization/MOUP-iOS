//
//  GoogleAuthService.swift
//  MOUP
//
//  Created by 송규섭 on 7/27/25.
//

import Foundation
import Alamofire

protocol GoogleAuthServiceProtocol {
    func signInWithGoogle(requestDTO: SignInRequestDTO) async -> LoginResponseEnum
}

final class GoogleAuthService: GoogleAuthServiceProtocol {
    func signInWithGoogle(requestDTO: SignInRequestDTO) async -> LoginResponseEnum {
        let request = AF.request(GoogleAuthRouter.signIn(requestDTO))
        let response = await request.serializingResponse(using: .data).response

        if let data = response.data,
           let bodyString = String(data: data, encoding: .utf8) {
            print("Response body: \(bodyString)")
        } else {
            print("Response body is nil or not utf8 decodable")
        }

        if let error = response.error {
            return .failure(NetworkError.invalidResponse(error))
        }

        guard let status = response.response?.statusCode else {
            return .failure(NetworkError.noResponse)
        }

        switch status {
        case 200:
            return .success
        case 404:
            return .notMember
        default:
            return .failure(NetworkError.serverError)
        }
    }
}
