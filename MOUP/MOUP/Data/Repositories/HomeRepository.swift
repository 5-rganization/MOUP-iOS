//
//  HomeRepository.swift
//  MOUP
//
//  Created by 송규섭 on 10/26/25.
//

import Foundation

final class HomeRepository: HomeRepositoryProtocol {
    private let homeService: HomeServiceProtocol
    private let homeMapper = HomeMapper()
    
    init(homeService: HomeServiceProtocol) {
        self.homeService = homeService
    }
    
    func fetchWorkerHomeData() async throws -> HomeWorkerSummary {
        let response = try await homeService.fetchWorkerHomeData()
        return homeMapper.mapToWorkerSummary(response)
    }
    
    func fetchOwnerHomeData() async throws -> HomeOwnerSummary {
        let response = try await homeService.fetchOwnerHomeData()
        return homeMapper.mapToOwnerSummary(response)
    }
}
