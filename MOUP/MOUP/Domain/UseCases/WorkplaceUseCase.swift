//
//  WorkplaceUseCase.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation

final class WorkplaceUseCase: WorkplaceUseCaseProtocol {
    private let workplaceRepository: WorkplaceRepositoryProtocol
    
    init(workplaceRepository: WorkplaceRepositoryProtocol) {
        self.workplaceRepository = workplaceRepository
    }
    
    func fetchAllWorkplace() async throws -> [WorkplaceSummary] {
        try await workplaceRepository.fetchWorkplaceList(isSharedOnly: false)
    }
    
    func fetchSharedWorkplaceOnly() async throws -> [WorkplaceSummary] {
        try await workplaceRepository.fetchWorkplaceList(isSharedOnly: true)
    }
    
    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplace {
        try await workplaceRepository.fetchWorkplaceByInviteCode(inviteCode: inviteCode)
    }
    
    func fetchInviteCode(workplaceId: Int, forceGenerate: Bool) async throws -> InviteCodeInfo {
        try await workplaceRepository.fetchInviteCode(workplaceId: workplaceId, forceGenerate: forceGenerate)
    }
    
    func createWorkplace(request: WorkplaceCreateRequestDTO) async throws -> WorkplaceCreate {
        try await workplaceRepository.createWorkplace(request: request)
    }
    
    func createOwnerWorkplace(request: OwnerWorkplaceCreateRequestDTO) async throws -> WorkplaceCreate {
        try await workplaceRepository.createOwnerWorkplace(request: request)
    }
    
    func joinWorkplace(request: WorkplaceJoinRequestDTO) async throws -> WorkplaceJoinResponseDTO {
        try await workplaceRepository.joinWorkplace(request: request)
    }
    
    func deleteWorkplace(workplaceId: Int) async throws {
        try await workplaceRepository.deleteWorkplace(workplaceId: workplaceId)
    }
    
    func fetchWorkplaceDetail(workplaceId: Int) async throws -> WorkplaceDetailResponseDTO {
        try await workplaceRepository.fetchWorkplaceDetail(workplaceId: workplaceId)
    }
    
    func updateWorkplace(workplaceId: Int, request: UpdateWorkplaceRequestDTO) async throws {
        try await workplaceRepository.updateWorkplace(workplaceId: workplaceId, request: request)
    }
    
    func approveJoinRequest(workplaceId: Int, workerId: Int) async throws {
        try await workplaceRepository.approveJoinRequest(
            workplaceId: workplaceId,
            workerId: workerId
        )
    }
    
    func rejectJoinRequest(workplaceId: Int, workerId: Int) async throws {
        try await workplaceRepository.rejectJoinRequest(
            workplaceId: workplaceId,
            workerId: workerId
        )
    }
}
