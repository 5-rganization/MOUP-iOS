//
//  WorkplaceRepository.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation

final class WorkplaceRepository: WorkplaceRepositoryProtocol {
    private let workplaceService: WorkplaceServiceProtocol
    
    init(workplaceService: WorkplaceServiceProtocol) {
        self.workplaceService = workplaceService
    }
    
    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplace {
        let response = try await workplaceService.fetchWorkplaceByInviteCode(inviteCode: inviteCode)
        return InviteCodeWorkplace(
            workplaceId: response.workplaceId,
            workplaceName: response.workplaceName,
            categoryName: response.categoryName,
            address: response.address,
            latitude: response.latitude,
            longitude: response.longitude
        )
    }
    
    func fetchInviteCode(workplaceId: Int, forceGenerate: Bool) async throws -> InviteCodeInfo {
        let response = try await workplaceService.fetchInviteCode(workplaceId: workplaceId, forceGenerate: forceGenerate)
        return InviteCodeInfo(
            inviteCode: response.inviteCode,
            returnAlreadyExists: response.returnAlreadyExists
        )
    }
        
    func createWorkplace(request: WorkplaceCreateRequestDTO) async throws -> WorkplaceCreate {
        let response = try await workplaceService.createWorkplace(request: request)
        return WorkplaceCreate(workplaceId: response.workplaceId)
    }
}
