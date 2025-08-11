//
//  AppleAuthService.swift
//  MOUP
//
//  Created by 서동환 on 8/8/25.
//

import OSLog

import Alamofire

protocol AppleAuthServiceProtocol: AnyObject {
    func signIn(requestDTO: SignInRequestDTO) async throws -> SignInResponseDTO
    func register(requestDTO: RegisterRequestDTO) async throws -> RegisterResponseDTO
}

final class AppleAuthService: AppleAuthServiceProtocol {
    
    // MARK: - Properties
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    // MARK: - signIn
    func signIn(requestDTO: SignInRequestDTO) async throws -> SignInResponseDTO {
        let request = AF.request(AppleAuthRouter.signIn(requestDTO))
        let response = await request.serializingDecodable(SignInResponseDTO.self).response
        logger.debug("\(String(reflecting: response), privacy: .private)")
        
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
    
    // MARK: - register
    func register(requestDTO: RegisterRequestDTO) async throws -> RegisterResponseDTO {
        let request = AF.request(AppleAuthRouter.register(requestDTO))
        let response = await request.serializingDecodable(RegisterResponseDTO.self).response
        logger.debug("\(String(reflecting: response), privacy: .private)")
        
        // TODO: 중복 코드 통합 필요
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
