//
//  RoutineRepositoryProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 10/31/25.
//

import Foundation

protocol RoutineRepositoryProtocol: AnyObject {
    func fetchTodayRoutines() async throws -> [TodayRoutine]
    func fetchWorkRoutines(workId: Int) async throws -> [RoutineSummary]
    func fetchAllRoutines() async throws -> [RoutineSummary]
    func fetchRoutineDetail(routineId: Int) async throws -> RoutineDetail
    func createRoutine(
        name: String,
        alarmTime: String,
        tasks: [(content: String, orderIndex: Int)]
    ) async throws -> Int
    func updateRoutine(
        routineId: Int,
        name: String,
        alarmTime: String,
        tasks: [(content: String, orderIndex: Int)]
    ) async throws
}
