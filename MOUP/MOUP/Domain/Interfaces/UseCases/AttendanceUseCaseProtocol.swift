//
//  AttendanceUseCaseProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 11/4/25.
//

import Foundation

protocol AttendanceUseCaseProtocol: AnyObject {
    func fetchWorkerWorkplaceAttendanceHistory(workplaceId: Int) async throws -> WorkerWorkplaceAttendanceHistory
    func fetchOwnerWorkplaceAttendanceHistory(workplaceId: Int, workerId: Int) async throws -> OwnerWorkplaceAttendanceHistory
}
