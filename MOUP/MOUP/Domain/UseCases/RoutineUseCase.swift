//
//  RoutineUseCase.swift
//  MOUP
//
//  Created by 송규섭 on 10/31/25.
//

import Foundation

final class RoutineUseCase: RoutineUseCaseProtocol {
    private let routineRepository: RoutineRepositoryProtocol
    
    init(routineRepository: RoutineRepositoryProtocol) {
        self.routineRepository = routineRepository
    }
    
    func fetchTodayRoutines() async throws -> [TodayRoutine] {
        try await routineRepository.fetchTodayRoutines()
    }
    
    func fetchWorkRoutines(workId: Int) async throws -> [RoutineSummary] {
        try await routineRepository.fetchWorkRoutines(workId: workId)
    }
    
    func fetchAllRoutines() async throws -> [RoutineSummary] {
        try await routineRepository.fetchAllRoutines()
    }
}
