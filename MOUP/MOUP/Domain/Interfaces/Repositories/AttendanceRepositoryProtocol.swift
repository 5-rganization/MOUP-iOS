//
//  AttendanceRepositoryProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 11/4/25.
//

import Foundation

protocol AttendanceRepositoryProtocol: AnyObject {
    func fetchWorkerWorkplaceAttendanceHistory(workplaceId: Int) async throws -> WorkerWorkplaceAttendanceHistory
    func fetchOwnerWorkplaceAttendanceHistory(workplaceId: Int, workerId: Int) async throws -> OwnerWorkplaceAttendanceHistory
    func fetchWorkplaceWorkers(workplaceId: Int, isActiveOnly: Bool) async throws -> [WorkerSummary]
    func startWork(workplaceId: Int) async throws
    func endWork(workplaceId: Int) async throws
}
