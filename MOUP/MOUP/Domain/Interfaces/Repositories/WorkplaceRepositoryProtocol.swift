//
//  WorkplaceRepositoryProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation

protocol WorkplaceRepositoryProtocol: AnyObject {
    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplace
    func fetchInviteCode(workplaceId: Int, forceGenerate: Bool) async throws -> InviteCodeInfo
    func createWorkplace(request: WorkplaceCreateRequestDTO) async throws -> WorkplaceCreate
}
