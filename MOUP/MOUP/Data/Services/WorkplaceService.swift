//
//  WorkplaceService.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation
import Alamofire

protocol WorkplaceServiceProtocol: AnyObject {
    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplaceResponseDTO
}

final class WorkplaceService: WorkplaceServiceProtocol {
    private let session = NetworkManager.shared.session
    
    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplaceResponseDTO {
        let request = session.request(WorkplaceRouter.fetchWorkplaceByInviteCode(inviteCode: inviteCode))
        let response = await request.serializingDecodable(InviteCodeWorkplaceResponseDTO.self).response

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
        case 403:
            print(WorkplaceError.invalidRole.debugDescription!)
            throw WorkplaceError.invalidRole
        case 404:
            print(WorkplaceError.notFound.debugDescription!)
            throw WorkplaceError.notFound
        case 409:
            print(WorkplaceError.alreadyExists.debugDescription!)
            throw WorkplaceError.alreadyExists
        default:
            print(NetworkError.serverError.debugDescription!)
            throw NetworkError.serverError
        }
    }
}
