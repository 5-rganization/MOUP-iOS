//
//  RoutineUseCaseProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 10/31/25.
//

import Foundation

protocol RoutineUseCaseProtocol: AnyObject {
    func fetchTodayRoutines() async throws -> [TodayRoutine]
    func fetchWorkRoutines(workId: Int) async throws -> [RoutineSummary]
    func fetchAllRoutines() async throws -> [RoutineSummary]
    func createRoutine(
        name: String,
        alarmTime: String,
        tasks: [(content: String, orderIndex: Int)]
    ) async throws -> RoutineSummary
    func updateRoutine(
        routineId: Int,
        name: String,
        alarmTime: String,
        tasks: [(content: String, orderIndex: Int)]
    ) async throws
}
