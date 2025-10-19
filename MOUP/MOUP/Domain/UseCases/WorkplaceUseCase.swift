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
    
    func fetchWorkplaceByInviteCode(inviteCode: String) async throws -> InviteCodeWorkplace {
        try await workplaceRepository.fetchWorkplaceByInviteCode(inviteCode: inviteCode)
    }
}
