//
//  WorkplaceUseCaseProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation

protocol WorkplaceUseCaseProtocol: AnyObject {
    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplace
    func createWorkplace(request: WorkplaceCreateRequestDTO) async throws -> WorkplaceCreate
}
