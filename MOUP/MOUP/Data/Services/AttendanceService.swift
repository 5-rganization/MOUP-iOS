//
//  AttendanceService.swift
//  MOUP
//
//  Created by 송규섭 on 11/4/25.
//

import os
import Foundation

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AttendanceService")

protocol AttendanceServiceProtocol: AnyObject {
    func fetchWorkerWorkplaceAttendanceHistory(workplaceId: Int) async throws -> WorkerWorkplaceAttendanceHistoryDTO
    func fetchOwnerWorkplaceAttendanceHistory(workplaceId: Int, workerId: Int) async throws -> OwnerWorkplaceAttendanceHistoryDTO
    func fetchWorkplaceWorkers(workplaceId: Int, isActiveOnly: Bool) async throws -> [WorkerSummary]
}

final class AttendanceService: AttendanceServiceProtocol {
    private let session = NetworkManager.shared.session
    
    func fetchWorkerWorkplaceAttendanceHistory(workplaceId: Int) async throws -> WorkerWorkplaceAttendanceHistoryDTO {
        let request = session.request(AttendanceRouter.fetchWorkerWorkplaceAttendanceHistory(workplaceId: workplaceId))
        let response = await request.serializingDecodable(WorkerWorkplaceAttendanceHistoryDTO.self).response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        logger.debug("statusCode: \(statusCode)")
        
        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 400:
            throw AttendanceError.invalidRequest
        case 403:
            throw AttendanceError.unauthorizedAccess
        case 404:
            throw AttendanceError.notFound
        default:
            throw NetworkError.serverError
        }
    }
    
    func fetchOwnerWorkplaceAttendanceHistory(workplaceId: Int, workerId: Int) async throws -> OwnerWorkplaceAttendanceHistoryDTO {
        let request = session.request(
            AttendanceRouter.fetchOwnerWorkplaceAttendanceHistory(
                workplaceId: workplaceId,
                workerId: workerId
            )
        )
        let response = await request.serializingDecodable(OwnerWorkplaceAttendanceHistoryDTO.self).response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        logger.debug("statusCode: \(statusCode)")
        
        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        case 400:
            throw AttendanceError.invalidRequest
        case 403:
            throw AttendanceError.unauthorizedAccess
        case 404:
            throw AttendanceError.notFound
        default:
            throw NetworkError.serverError
        }
    }
}
