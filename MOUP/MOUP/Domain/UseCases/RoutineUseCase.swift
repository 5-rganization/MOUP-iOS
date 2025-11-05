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
    
    func createRoutine(
        name: String,
        alarmTime: String,
        tasks: [(content: String, orderIndex: Int)]
    ) async throws -> RoutineSummary {
        let routineId = try await routineRepository.createRoutine(
            name: name,
            alarmTime: alarmTime,
            tasks: tasks
        )

        return RoutineSummary(
            routineId: routineId,
            routineName: name,
            alarmTime: alarmTime
        )
    }

    func updateRoutine(
        routineId: Int,
        name: String,
        alarmTime: String,
        tasks: [(content: String, orderIndex: Int)]
    ) async throws {
        try await routineRepository.updateRoutine(
            routineId: routineId,
            name: name,
            alarmTime: alarmTime,
            tasks: tasks
        )
    }
}
