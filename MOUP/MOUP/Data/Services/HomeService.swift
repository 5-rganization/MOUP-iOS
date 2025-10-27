//
//  HomeService.swift
//  MOUP
//
//  Created by 송규섭 on 10/26/25.
//

import os
import Foundation

protocol HomeServiceProtocol: AnyObject {
    func fetchWorkerHomeData() async throws -> HomeWorkerResponseDTO
    func fetchOwnerHomeData() async throws -> HomeOwnerResponseDTO
}

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "HomeService")

final class HomeService: HomeServiceProtocol {
    private lazy var session = NetworkManager.shared.session
    
    func fetchWorkerHomeData() async throws -> HomeWorkerResponseDTO {
        let request = session.request(HomeRouter.fetchHomeData)
        let response = await request.serializingDecodable(HomeWorkerResponseDTO.self).response
        
        let statusCode = response.response?.statusCode
        logger.debug("statusCode: \(statusCode ?? 0)")
        
        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 403:
            logger.error("\(WorkplaceError.invalidRole.debugDescription ?? "Unknown error")")
            throw WorkplaceError.invalidRole
        default:
            logger.error("\(NetworkError.serverError.debugDescription ?? "Unknown error")")
            throw NetworkError.serverError
        }
    }
    
    // 위 함수와 중복되는 부분이 많으나, 역할 별 응답 DTO에 대한 확실한 분기를 위해 로직 분기함
    func fetchOwnerHomeData() async throws -> HomeOwnerResponseDTO {
        let request = session.request(HomeRouter.fetchHomeData)
        let response = await request.serializingDecodable(HomeOwnerResponseDTO.self).response
        
        let statusCode = response.response?.statusCode
        logger.debug("statusCode: \(statusCode ?? 0)")
        
        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 403:
            logger.error("\(WorkplaceError.invalidRole.debugDescription ?? "Unknown error")")
            throw WorkplaceError.invalidRole
        default:
            logger.error("\(NetworkError.serverError.debugDescription ?? "Unknown error")")
            throw NetworkError.serverError
        }
    }
}
