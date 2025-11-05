//
//  AttendanceRepository.swift
//  MOUP
//
//  Created by 송규섭 on 11/4/25.
//

import Foundation

final class AttendanceRepository: AttendanceRepositoryProtocol {
    private let attendanceService: AttendanceServiceProtocol
    private let attendanceMapper = AttendanceMapper() // 유틸리티 성격이므로 직접 생성
    
    init(attendanceService: AttendanceServiceProtocol) {
        self.attendanceService = attendanceService
    }
    
    func fetchWorkerWorkplaceAttendanceHistory(workplaceId: Int) async throws -> WorkerWorkplaceAttendanceHistory {
        let response = try await attendanceService.fetchWorkerWorkplaceAttendanceHistory(workplaceId: workplaceId)
        return attendanceMapper.mapToWorkerWorkplaceAttendanceHistory(dto: response)
    }
    
    func fetchOwnerWorkplaceAttendanceHistory(workplaceId: Int, workerId: Int) async throws -> OwnerWorkplaceAttendanceHistory {
        let response = try await attendanceService.fetchOwnerWorkplaceAttendanceHistory(
            workplaceId: workplaceId,
            workerId: workerId
        )
        return attendanceMapper.mapToOwnerWorkplaceAttendanceHistory(dto: response)
    }
    
    func fetchWorkplaceWorkers(workplaceId: Int, isActiveOnly: Bool) async throws -> [WorkerSummary] {
        let response = try await attendanceService.fetchWorkplaceWorkers(workplaceId: workplaceId, isActiveOnly: isActiveOnly)
        return response.workerSummaryInfoList.map {
            return WorkerSummary(
                id: $0.workerId,
                workerBasedLabelColorStr: $0.workerBasedLabelColor,
                ownerBasedLabelColorStr: $0.ownerBasedLabelColor,
                nickname: $0.nickname,
                profileImg: $0.profileImg
            )
        }
    }
    
    func startWork(workplaceId: Int) async throws {
        try await attendanceService.startWork(workplaceId: workplaceId)
    }
    
    func endWork(workplaceId: Int) async throws {
        try await attendanceService.endWork(workplaceId: workplaceId)
    }
}
