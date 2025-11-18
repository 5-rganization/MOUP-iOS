//
//  WorkplaceUseCaseProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation

protocol WorkplaceUseCaseProtocol: AnyObject {
    func fetchAllWorkplace() async throws -> [WorkplaceSummary]
    func fetchSharedWorkplaceOnly() async throws -> [WorkplaceSummary]
    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplace
    func fetchInviteCode(workplaceId: Int, forceGenerate: Bool) async throws -> InviteCodeInfo
    func createWorkplace(request: WorkplaceCreateRequestDTO) async throws -> WorkplaceCreate
    func createOwnerWorkplace(request: OwnerWorkplaceCreateRequestDTO) async throws -> WorkplaceCreate
    func joinWorkplace(request: WorkplaceJoinRequestDTO) async throws -> WorkplaceJoinResponseDTO
    func deleteWorkplace(workplaceId: Int) async throws
    func fetchWorkplaceDetail(workplaceId: Int) async throws -> WorkplaceDetailResponseDTO
    func updateWorkplace(workplaceId: Int, request: UpdateWorkplaceRequestDTO) async throws
    func approveJoinRequest(workplaceId: Int, workerId: Int) async throws
    func rejectJoinRequest(workplaceId: Int, workerId: Int) async throws
}
