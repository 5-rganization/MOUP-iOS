//
//  RoutineRepository.swift
//  MOUP
//
//  Created by 송규섭 on 10/31/25.
//

import Foundation

final class RoutineRepository: RoutineRepositoryProtocol {
    private let routineService: RoutineServiceProtocol
    
    init(routineService: RoutineServiceProtocol) {
        self.routineService = routineService
    }
    
    func fetchTodayRoutines() async throws -> [TodayRoutine] {
        let response = try await routineService.fetchTodaysRoutine()
        let todayRoutines = response.todayWorkRoutineCountList.map { dto in
            TodayRoutine(
                workId: dto.workId,
                workplaceSummary: WorkplaceSummary(
                    id: dto.workplaceSummaryInfo.workplaceId,
                    name: dto.workplaceSummaryInfo.workplaceName,
                    isShared: dto.workplaceSummaryInfo.isShared
                ),
                startTime: dto.startTime,
                endTime: dto.endTime,
                workMinutes: dto.workMinutes,
                routineCount: dto.routineCount
            )
        }
        return todayRoutines
    }
    
    func fetchWorkRoutines(workId: Int) async throws -> [RoutineSummary] {
        let response = try await routineService.fetchWorkRoutines(workId: workId)
        let workRoutines = response.routineSummaryInfoList.map { dto in
            RoutineSummary(
                routineId: dto.routineId,
                routineName: dto.routineName,
                alarmTime: dto.alarmTime
            )
        }
        
        return workRoutines
    }
    
    func fetchAllRoutines() async throws -> [RoutineSummary] {
        let response = try await routineService.fetchAllRoutines()
        let routines = response.routineSummaryInfoList.map { dto in
            RoutineSummary(
                routineId: dto.routineId,
                routineName: dto.routineName,
                alarmTime: dto.alarmTime
            )
        }
        
        return routines
    }
    
    func createRoutine(
        name: String,
        alarmTime: String,
        tasks: [(content: String, orderIndex: Int)]
    ) async throws -> Int {
        let request = CreateRoutineRequestDTO(
            routineName: name,
            alarmTime: alarmTime,
            routineTaskList: tasks.map {
                RoutineTaskDTO(
                    content: $0.content,
                    orderIndex: $0.orderIndex
                )
            })
        
        return try await routineService.createRoutine(request: request)
    }
}
