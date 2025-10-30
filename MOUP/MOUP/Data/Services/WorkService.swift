//
//  WorkService.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

import OSLog

import Alamofire

protocol WorkServiceProtocol {
    func createMyWork(workplaceId: Int, requestDTO: MyWorkCreateRequestDTO) async throws -> WorkCreateResponseDTO
    func createWorkerWork(workplaceId: Int, workerId: Int, requestDTO: WorkerWorkCreateRequestDTO) async throws -> WorkCreateResponseDTO
    
    func fetchWorkDetail(workId: Int) async throws -> WorkDetailResponseDTO
    func fetchWorkSummary(workId: Int) async throws -> WorkSummaryResponseDTO
    func fetchAllMyWorkList(baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    func fetchWorkplaceMyWorkList(workplaceId: Int, baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    func fetchWorkplaceAllWorkList(workplaceId: Int, baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    
    func updateMyWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws -> WorkCreateResponseDTO?
    func updateWorkerWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws -> WorkCreateResponseDTO?
    
    func deleteWork(workId: Int) async throws
    func deleteRecurringWork(workId: Int) async throws
    
    func startWork(workplaceId: Int) async throws -> WorkCreateResponseDTO?
    func endWork(workplaceId: Int) async throws
}

final class WorkService: WorkServiceProtocol {
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let session = NetworkManager.shared.session
    
    func createMyWork(workplaceId: Int, requestDTO: MyWorkCreateRequestDTO) async throws -> WorkCreateResponseDTO {
        let request = AF.request(WorkRouter.createMyWork(workplaceId: workplaceId, dto: requestDTO))
        let response = await request.serializingDecodable(WorkCreateResponseDTO.self).response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 201:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func createWorkerWork(workplaceId: Int, workerId: Int, requestDTO: WorkerWorkCreateRequestDTO) async throws -> WorkCreateResponseDTO {
        let request = AF.request(WorkRouter.createWorkerWork(workplaceId: workplaceId, workerId: workerId, dto: requestDTO))
        let response = await request.serializingDecodable(WorkCreateResponseDTO.self).response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 201:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func fetchWorkDetail(workId: Int) async throws -> WorkDetailResponseDTO {
        let request = AF.request(WorkRouter.fetchWork(workId: workId, viewQueryType: .detail))
        let response = await request.serializingDecodable(WorkDetailResponseDTO.self).response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 200:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func fetchWorkSummary(workId: Int) async throws -> WorkSummaryResponseDTO {
        let request = AF.request(WorkRouter.fetchWork(workId: workId, viewQueryType: .summary))
        let response = await request.serializingDecodable(WorkSummaryResponseDTO.self).response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 200:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func fetchAllMyWorkList(baseYearMonth: String) async throws -> WorkCalendarListResponseDTO {
        let request = AF.request(WorkRouter.fetchAllMyWorkList(baseYearMonth: baseYearMonth))
        let response = await request.serializingDecodable(WorkCalendarListResponseDTO.self).response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 200:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func fetchWorkplaceMyWorkList(workplaceId: Int, baseYearMonth: String) async throws -> WorkCalendarListResponseDTO {
        let request = AF.request(WorkRouter.fetchWorkplaceMyWorkList(workplaceId: workplaceId, baseYearMonth: baseYearMonth))
        let response = await request.serializingDecodable(WorkCalendarListResponseDTO.self).response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 200:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func fetchWorkplaceAllWorkList(workplaceId: Int, baseYearMonth: String) async throws -> WorkCalendarListResponseDTO {
        let request = AF.request(WorkRouter.fetchWorkplaceAllWorkList(workplaceId: workplaceId, baseYearMonth: baseYearMonth))
        let response = await request.serializingDecodable(WorkCalendarListResponseDTO.self).response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 200:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func updateMyWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws -> WorkCreateResponseDTO? {
        let request = AF.request(WorkRouter.updateMyWork(workId: workId, dto: requestDTO))
        let response = await request.serializingDecodable(WorkCreateResponseDTO.self).response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 201:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        case 204:
            return nil
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func updateWorkerWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws -> WorkCreateResponseDTO? {
        let request = AF.request(WorkRouter.updateWorkerWork(workplaceId: workplaceId, workerId: workerId, workId: workId, dto: requestDTO))
        let response = await request.serializingDecodable(WorkCreateResponseDTO.self).response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 201:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        case 204:
            return nil
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func deleteWork(workId: Int) async throws {
        let request = AF.request(WorkRouter.deleteWork(workId: workId))
        let response = await request.serializingData().response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 204:
            return
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func deleteRecurringWork(workId: Int) async throws {
        let request = AF.request(WorkRouter.deleteRecurringWork(workId: workId))
        let response = await request.serializingData().response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 204:
            return
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func startWork(workplaceId: Int) async throws -> WorkCreateResponseDTO? {
        let request = AF.request(WorkRouter.startWork(workplaceId: workplaceId))
        let response = await request.serializingDecodable(WorkCreateResponseDTO.self).response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 201:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        case 204:
            return nil
        case 409:
            let error = WorkError.alreadyStarted
            logger.error("\(error.debugDescription)")
            throw error
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func endWork(workplaceId: Int) async throws {
        let request = AF.request(WorkRouter.endWork(workplaceId: workplaceId))
        let response = await request.serializingData().response
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 204:
            return
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
}

private extension WorkService {
    func handleCommonWorkError(statusCode: Int) throws -> Never {
        let error: Error
        
        switch statusCode {
        case 400:
            error = WorkError.invalidVariableOrParameter
        case 403:
            error = WorkError.invalidPermission
        case 404:
            error = WorkError.notFound
        case 422:
            error = WorkError.invalidFieldValue
        default:
            error = NetworkError.serverError
        }
        
        if let workError = error as? WorkError {
            logger.error("\(workError.debugDescription)")
        } else if let networkError = error as? NetworkError {
            logger.error("\(networkError.debugDescription ?? "NetworkError")")
        }
        
        throw error
    }
    
    /// Alamofire 응답(Response)을 디버그 로그로 출력합니다.
    /// - Parameter response: Alamofire의 `DataResponse`
    /// - Parameter functionName: 이 로그를 호출한 상위 함수의 이름 (자동으로 채워짐)
    func logResponse<T>(_ response: DataResponse<T, AFError>, _ functionName: String = #function) {
        logger.debug("[\(functionName)] Server Response Value: \(String(describing: response.value))")
        logger.debug("[\(functionName)] Server StatusCode: \(String(describing: response.response?.statusCode))")
        
        // 디코딩 실패 시 원본 데이터 출력
        if response.value == nil, let data = response.data, let rawString = String(data: data, encoding: .utf8) {
            logger.debug("[\(functionName)] Decoding failed - Raw Data: \(rawString)")
        }
    }
}
