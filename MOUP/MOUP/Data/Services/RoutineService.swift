//
//  RoutineService.swift
//  MOUP
//
//  Created by 송규섭 on 10/31/25.
//

import os
import Foundation
import Alamofire

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "RoutineService")

protocol RoutineServiceProtocol: AnyObject {
    func fetchTodaysRoutine() async throws -> TodayRoutineResponseDTO
    func fetchWorkRoutines(workId: Int) async throws -> WorkRoutineResponseDTO
    func fetchAllRoutines() async throws -> AllRoutineResponseDTO
    func createRoutine(request: CreateRoutineRequestDTO) async throws -> Int
    func updateRoutine(routineId: Int, request: UpdateRoutineRequestDTO) async throws
}

final class RoutineService: RoutineServiceProtocol {
    private let session = NetworkManager.shared.session
    
    func fetchTodaysRoutine() async throws -> TodayRoutineResponseDTO {
        let request = session.request(RoutineRouter.fetchTodayRoutines)
        let response = await request.serializingDecodable(TodayRoutineResponseDTO.self).response
        
        let statusCode = response.response?.statusCode
        logger.debug("statusCode: \(statusCode ?? 0)")
        
        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        default:
            throw NetworkError.serverError
        }
    }
    
    func fetchWorkRoutines(workId: Int) async throws -> WorkRoutineResponseDTO {
        let request = session.request(RoutineRouter.fetchWorkRoutines(workId: workId))
        let response = await request.serializingDecodable(WorkRoutineResponseDTO.self).response
        
        let statusCode = response.response?.statusCode
        logger.debug("statusCode: \(statusCode ?? 0)")
        
        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        default:
            throw NetworkError.serverError
        }
    }
    
    func fetchAllRoutines() async throws -> AllRoutineResponseDTO {
        let request = session.request(RoutineRouter.fetchAllRoutines)
        let response = await request.serializingDecodable(AllRoutineResponseDTO.self).response
        
        let statusCode = response.response?.statusCode
        logger.debug("statusCode: \(statusCode ?? 0)")
        
        switch statusCode {
        case 200:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            return dto
        default:
            throw NetworkError.serverError
        }
    }
    
    func createRoutine(request: CreateRoutineRequestDTO) async throws -> Int {
        let request = session.request(RoutineRouter.createRoutine(request: request))
        let response = await request.serializingDecodable(CreateRoutineResponseDTO.self).response

        let statusCode = response.response?.statusCode
        logger.debug("statusCode: \(statusCode ?? 0)")

        switch statusCode {
        case 201:
            guard let dto = response.value else {
                throw NetworkError.noResponse
            }
            logger.debug("루틴 생성 성공 - routineId: \(dto.routineId)")
            return dto.routineId
        default:
            logger.error("루틴 생성 실패 - statusCode: \(statusCode ?? 0)")
            throw NetworkError.serverError
        }
    }

    func updateRoutine(routineId: Int, request: UpdateRoutineRequestDTO) async throws {
        let request = session.request(RoutineRouter.updateRoutine(routineId: routineId, request: request))
        let response = await request.serializingData().response

        let statusCode = response.response?.statusCode
        logger.debug("statusCode: \(statusCode ?? 0)")

        switch statusCode {
        case 200:
            logger.debug("루틴 업데이트 성공 - routineId: \(routineId)")
            return
        default:
            logger.error("루틴 업데이트 실패 - statusCode: \(statusCode ?? 0)")
            throw NetworkError.serverError
        }
    }
}
