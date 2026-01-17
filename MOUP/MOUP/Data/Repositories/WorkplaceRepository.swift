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
    
    func fetchWorkplaceList(isSharedOnly: Bool) async throws -> [WorkplaceSummary] {
        let response = try await workplaceService.fetchWorkplaceList(isSharedOnly: isSharedOnly)
        return response.workplaceSummaryInfoList.map { WorkplaceSummary(id: $0.workplaceId, name: $0.workplaceName, isShared: $0.isShared) }
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
    
    func createOwnerWorkplace(request: OwnerWorkplaceCreateRequestDTO) async throws -> WorkplaceCreate {
        let response = try await workplaceService.createOwnerWorkplace(request: request)
        return WorkplaceCreate(workplaceId: response.workplaceId)
    }
    
    func joinWorkplace(request: WorkplaceJoinRequestDTO) async throws -> WorkplaceJoinResponseDTO {
        let response = try await workplaceService.joinWorkplace(request: request)
        return WorkplaceJoinResponseDTO(
            workplaceId: response.workplaceId,
            workerId: response.workerId
        )
    }
    
    func deleteWorkplace(workplaceId: Int) async throws {
        try await workplaceService.deleteWorkplace(workplaceId: workplaceId)
    }
    
    func fetchWorkplaceDetail(workplaceId: Int) async throws -> WorkplaceDetailResponseDTO {
        try await workplaceService.fetchWorkplaceDetail(workplaceId: workplaceId)
    }
    
    func updateWorkplace(workplaceId: Int, request: UpdateWorkplaceRequestDTO) async throws {
        try await workplaceService.updateWorkplace(workplaceId: workplaceId, request: request)
    }

    func approveJoinRequest(workplaceId: Int, workerId: Int) async throws {
        try await workplaceService.approveJoinRequest(
            workplaceId: workplaceId,
            workerId: workerId
        )
    }
    
    func rejectJoinRequest(workplaceId: Int, workerId: Int) async throws {
        try await workplaceService.rejectJoinRequest(
            workplaceId: workplaceId,
            workerId: workerId
        )
    }
}
