//
//  HomeUseCase.swift
//  MOUP
//
//  Created by 송규섭 on 10/26/25.
//

import Foundation

final class HomeUseCase: HomeUseCaseProtocol {
    private let homeRepository: HomeRepositoryProtocol
    
    init(homeRepository: HomeRepositoryProtocol) {
        self.homeRepository = homeRepository
    }
    
    func fetchWorkerHomeData() async throws -> HomeWorkerSummary {
        try await homeRepository.fetchWorkerHomeData()
    }
    
    func fetchOwnerHomeData() async throws -> HomeOwnerSummary {
        try await homeRepository.fetchOwnerHomeData()
    }
}
