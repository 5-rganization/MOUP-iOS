//
//  AttendanceUseCase.swift
//  MOUP
//
//  Created by 송규섭 on 11/4/25.
//

import Foundation

final class AttendanceUseCase: AttendanceUseCaseProtocol {
    private let attendanceRepository: AttendanceRepositoryProtocol
    
    init(attendanceRepository: AttendanceRepositoryProtocol) {
        self.attendanceRepository = attendanceRepository
    }
    
    func fetchWorkerWorkplaceAttendanceHistory(workplaceId: Int) async throws -> WorkerWorkplaceAttendanceHistory {
        try await attendanceRepository.fetchWorkerWorkplaceAttendanceHistory(workplaceId: workplaceId)
    }
    
    func fetchOwnerWorkplaceAttendanceHistory(workplaceId: Int, workerId: Int) async throws -> OwnerWorkplaceAttendanceHistory {
        try await attendanceRepository.fetchOwnerWorkplaceAttendanceHistory(workplaceId: workplaceId, workerId: workerId)
    }
    
    func fetchWorkplaceWorkers(workplaceId: Int, isActiveOnly: Bool) async throws -> [WorkerSummary] {
        try await attendanceRepository.fetchWorkplaceWorkers(workplaceId: workplaceId, isActiveOnly: isActiveOnly)
    }
    
    func startWork(workplaceId: Int) async throws {
        try await attendanceRepository.startWork(workplaceId: workplaceId)
    }
    
    func endWork(workplaceId: Int) async throws {
        try await attendanceRepository.endWork(workplaceId: workplaceId)
    }
}
