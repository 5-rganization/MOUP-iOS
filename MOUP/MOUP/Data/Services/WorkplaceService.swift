//
//  WorkplaceService.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import os
import Foundation
import OSLog

import Alamofire

protocol WorkplaceServiceProtocol: AnyObject {
    func fetchWorkplaceList(isSharedOnly: Bool) async throws -> WorkplaceSummaryListResponseDTO
    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplaceResponseDTO
    func fetchInviteCode(workplaceId: Int, forceGenerate: Bool) async throws -> InviteCodeResponseDTO
    func createWorkplace(request: WorkplaceCreateRequestDTO) async throws -> WorkplaceCreateResponseDTO
    func createOwnerWorkplace(request: OwnerWorkplaceCreateRequestDTO) async throws -> WorkplaceCreateResponseDTO
    func joinWorkplace(request: WorkplaceJoinRequestDTO) async throws -> WorkplaceJoinResponseDTO
    func deleteWorkplace(workplaceId: Int) async throws
    func fetchWorkplaceDetail(workplaceId: Int) async throws -> WorkplaceDetailResponseDTO
    func updateWorkplace(workplaceId: Int, request: UpdateWorkplaceRequestDTO) async throws -> Void

}

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: "WorkplaceService"))

final class WorkplaceService: WorkplaceServiceProtocol {
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let session = NetworkManager.shared.session
    
    func fetchWorkplaceList(isSharedOnly: Bool) async throws -> WorkplaceSummaryListResponseDTO {
        let request = session.request(WorkplaceRouter.fetchWorkplaceList(isSharedOnly: isSharedOnly))
        let response = await request.serializingDecodable(WorkplaceSummaryListResponseDTO.self).response
        
        logger.debug("\(String(describing: response.value))")
        logger.debug("\(String(describing: response.response?.statusCode))")
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        switch statusCode {
        case 200:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        default:
            print(NetworkError.serverError.debugDescription!)
            throw NetworkError.serverError
        }
    }
    
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
    
    func createOwnerWorkplace(request: OwnerWorkplaceCreateRequestDTO) async throws -> WorkplaceCreateResponseDTO {
        let request = session.request(WorkplaceRouter.createOwnerWorkplace(request: request))
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
    
    func joinWorkplace(request: WorkplaceJoinRequestDTO) async throws -> WorkplaceJoinResponseDTO {
        let request = session.request(WorkplaceRouter.joinWorkplace(request: request))
        let response = await request.serializingDecodable(WorkplaceJoinResponseDTO.self).response

        print("statusCode: \(response.response?.statusCode ?? 0)")

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
            throw WorkplaceError.notFound
        case 409:
            throw WorkplaceError.alreadyExists
        case 422:
            throw WorkplaceError.invalidField
        default:
            throw NetworkError.serverError
        }
    }
    
    func deleteWorkplace(workplaceId: Int) async throws {
        let request = session.request(WorkplaceRouter.deleteWorkplace(workplaceId: workplaceId))
        let response = await request.serializingData().response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        switch statusCode {
        case 204:
            return
        case 404:
            throw WorkplaceError.notFound
        default:
            throw NetworkError.serverError
        }
    }
    
    func fetchWorkplaceDetail(workplaceId: Int) async throws -> WorkplaceDetailResponseDTO {
        let request = session.request(WorkplaceRouter.fetchWorkplaceDetail(id: workplaceId))

        // 먼저 raw data로 받아서 JSON 출력
        let rawResponse = await request.serializingData().response

        logger.debug("statusCode: \(rawResponse.response?.statusCode ?? 0)")

        if let data = rawResponse.data,
           let json = String(data: data, encoding: .utf8) {
            print("[DEBUG] Workplace Detail Raw JSON:")
            print(json)
        }

        // 2️⃣ 이제 status 체크
        guard let statusCode = rawResponse.response?.statusCode else {
            throw NetworkError.noResponse
        }

        switch statusCode {
        case 200:
            // 3️⃣ 디코딩 시도
            do {
                let decoder = JSONDecoder()
                let dto = try decoder.decode(WorkplaceDetailResponseDTO.self, from: rawResponse.data ?? Data())
                return dto
            } catch {
                print("[DECODE ERROR] WorkplaceDetailResponseDTO decode failed")
                print(error)
                throw error
            }

        case 404:
            throw WorkplaceError.notFound

        default:
            throw NetworkError.serverError
        }
    }

    
    func updateWorkplace(workplaceId: Int, request: UpdateWorkplaceRequestDTO) async throws {
        let request = session.request(
            WorkplaceRouter.updateWorkplace(workplaceId: workplaceId, request: request)
        )
        
        let response = await request.serializingData().response
        
        logger.debug("statusCode: \(response.response?.statusCode ?? 0)")
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        switch statusCode {
        case 200, 204:
            return
        case 403:
            throw WorkplaceError.invalidRole
        case 404:
            throw WorkplaceError.notFound
        case 422:
            throw WorkplaceError.invalidField
        default:
            throw NetworkError.serverError
        }
    }

}
