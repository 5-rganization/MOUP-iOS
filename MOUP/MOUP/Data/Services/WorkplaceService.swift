//
//  WorkplaceService.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import os
import Foundation
import Alamofire

protocol WorkplaceServiceProtocol: AnyObject {
    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplaceResponseDTO
    func fetchInviteCode(workplaceId: Int, forceGenerate: Bool) async throws -> InviteCodeResponseDTO
    func createWorkplace(request: WorkplaceCreateRequestDTO) async throws -> WorkplaceCreateResponseDTO
}

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: "WorkplaceService"))

final class WorkplaceService: WorkplaceServiceProtocol {
    private let session = NetworkManager.shared.session

    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplaceResponseDTO {
        let request = session.request(WorkplaceRouter.fetchWorkplaceByInviteCode(inviteCode: inviteCode))
        let response = await request.serializingDecodable(InviteCodeWorkplaceResponseDTO.self).response

        logger.debug("statusCode: \(response.response?.statusCode ?? 0)")

        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }

        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 403:
            throw WorkplaceError.invalidRole
        case 404:
            throw WorkplaceError.notFound
        case 409:
            throw WorkplaceError.alreadyExists
        default:
            throw NetworkError.serverError
        }
    }

    func createWorkplace(request: WorkplaceCreateRequestDTO) async throws -> WorkplaceCreateResponseDTO {
        let request = session.request(WorkplaceRouter.createWorkplace(request: request))
        let response = await request.serializingDecodable(WorkplaceCreateResponseDTO.self).response
        
        print(response.value)
        print("statusCode: \(response.response?.statusCode ?? 0)")

        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }

        switch statusCode {
        case 201:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 403:
            throw WorkplaceError.invalidRole
        case 409:
            throw WorkplaceError.alreadyExists
        case 422:
            throw WorkplaceError.invalidField
        default:
            throw NetworkError.serverError
        }
    }
    
    func fetchInviteCode(workplaceId: Int, forceGenerate: Bool) async throws -> InviteCodeResponseDTO {
        let requestDTO = InviteCodeRequestDTO(forceGenerate: forceGenerate)
        let request = session.request(
            WorkplaceRouter.fetchInviteCode(
                workplaceId: workplaceId,
                requestDTO: requestDTO
            )
        )
        let response = await request.serializingDecodable(InviteCodeResponseDTO.self).response
        
        logger.debug("statusCode: \(response.response?.statusCode ?? 0)")

        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        switch statusCode {
        case 200, 201:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 403:
            throw WorkplaceError.invalidRole
        case 404:
            if let data = response.data,
               let rawString = String(data: data, encoding: .utf8) {
                logger.debug("\(rawString)")
            }
            throw WorkplaceError.notFound
        default:
            throw NetworkError.serverError
        }
    }
}
