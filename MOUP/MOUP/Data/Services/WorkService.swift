//
//  WorkService.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

import OSLog

import Alamofire
import Then

protocol WorkServiceProtocol {
    func createMyWork(workplaceId: Int, requestDTO: MyWorkCreateRequestDTO) async throws -> WorkCreateResponseDTO
    func createWorkersWork(workplaceId: Int, requestDTO: WorkersWorkCreateRequestDTO) async throws -> WorkersWorkCreateResponseDTO
    
    func fetchWorkDetail(workId: Int) async throws -> WorkDetailResponseDTO
    func fetchWorkSummary(workId: Int) async throws -> WorkSummaryResponseDTO
    func fetchAllMyWorkList(baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    func fetchWorkplaceMyWorkList(workplaceId: Int, baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    func fetchWorkplaceAllWorkList(workplaceId: Int, baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    
    func updateMySingleWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws
    func updateMyRecurringWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws -> WorkCreateResponseDTO
    func updateWorkerSingleWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws
    func updateWorkerRecurringWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws -> WorkCreateResponseDTO
    
    func deleteWork(workId: Int) async throws
    func deleteRecurringWork(workId: Int) async throws
    
    func startWork(workplaceId: Int) async throws -> WorkCreateResponseDTO?
    func endWork(workplaceId: Int) async throws
}

final class WorkService: WorkServiceProtocol {
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: self))
    
    private let session = NetworkManager.shared.session
    private let isoDecoder = JSONDecoder().then { $0.dateDecodingStrategy = .iso8601 }
    
    func createMyWork(workplaceId: Int, requestDTO: MyWorkCreateRequestDTO) async throws -> WorkCreateResponseDTO {
        let request = session.request(WorkRouter.createMyWork(workplaceId: workplaceId, dto: requestDTO))
        let response = await request.serializingDecodable(WorkCreateResponseDTO.self).response
        
        try checkCancellation(response)
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
    
    func createWorkersWork(workplaceId: Int, requestDTO: WorkersWorkCreateRequestDTO) async throws -> WorkersWorkCreateResponseDTO {
        let request = session.request(WorkRouter.createWorkersWork(workplaceId: workplaceId, dto: requestDTO))
        let response = await request.serializingDecodable(WorkersWorkCreateResponseDTO.self).response
        
        try checkCancellation(response)
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 200, 201:
            guard let dto = response.value else { throw NetworkError.noResponse }
            return dto
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func fetchWorkDetail(workId: Int) async throws -> WorkDetailResponseDTO {
        let request = session.request(WorkRouter.fetchWork(workId: workId, viewQueryType: .detail))
        let response = await request.serializingDecodable(WorkDetailResponseDTO.self, decoder: isoDecoder).response
        
        try checkCancellation(response)
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
        let request = session.request(WorkRouter.fetchWork(workId: workId, viewQueryType: .summary))
        let response = await request.serializingDecodable(WorkSummaryResponseDTO.self, decoder: isoDecoder).response
        
        try checkCancellation(response)
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
        let request = session.request(WorkRouter.fetchAllMyWorkList(baseYearMonth: baseYearMonth))
        let response = await request.serializingDecodable(WorkCalendarListResponseDTO.self, decoder: isoDecoder).response
        
        try checkCancellation(response)
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
        let request = session.request(WorkRouter.fetchWorkplaceMyWorkList(workplaceId: workplaceId, baseYearMonth: baseYearMonth))
        let response = await request.serializingDecodable(WorkCalendarListResponseDTO.self, decoder: isoDecoder).response
        
        try checkCancellation(response)
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
        let request = session.request(WorkRouter.fetchWorkplaceAllWorkList(workplaceId: workplaceId, baseYearMonth: baseYearMonth))
        let response = await request.serializingDecodable(WorkCalendarListResponseDTO.self, decoder: isoDecoder).response
        
        try checkCancellation(response)
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
    
    func updateMySingleWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws {
        let request = session.request(WorkRouter.updateMySingleWork(workId: workId, dto: requestDTO))
        let response = await request.serializingData().response
        
        try checkCancellation(response)
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 204:
            return
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func updateMyRecurringWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws -> WorkCreateResponseDTO {
        let request = session.request(WorkRouter.updateMyRecurringWork(workId: workId, dto: requestDTO))
        let response = await request.serializingDecodable(WorkCreateResponseDTO.self, decoder: isoDecoder).response
        
        try checkCancellation(response)
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
    
    func updateWorkerSingleWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws {
        let request = session.request(WorkRouter.updateWorkerSingleWork(workplaceId: workplaceId, workerId: workerId, workId: workId, dto: requestDTO))
        let response = await request.serializingData().response
        
        try checkCancellation(response)
        logResponse(response)
        
        guard let statusCode = response.response?.statusCode else { throw NetworkError.noResponse }
        
        switch statusCode {
        case 204:
            return
        default:
            try handleCommonWorkError(statusCode: statusCode)
        }
    }
    
    func updateWorkerRecurringWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws -> WorkCreateResponseDTO {
        let request = session.request(WorkRouter.updateWorkerRecurringWork(workplaceId: workplaceId, workerId: workerId, workId: workId, dto: requestDTO))
        let response = await request.serializingDecodable(WorkCreateResponseDTO.self, decoder: isoDecoder).response
        
        try checkCancellation(response)
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
    
    func deleteWork(workId: Int) async throws {
        let request = session.request(WorkRouter.deleteWork(workId: workId))
        let response = await request.serializingData().response
        
        try checkCancellation(response)
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
        let request = session.request(WorkRouter.deleteRecurringWork(workId: workId))
        let response = await request.serializingData().response
        
        try checkCancellation(response)
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
        let request = session.request(WorkRouter.startWork(workplaceId: workplaceId))
        let response = await request.serializingDecodable(WorkCreateResponseDTO.self).response
        
        try checkCancellation(response)
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
        let request = session.request(WorkRouter.endWork(workplaceId: workplaceId))
        let response = await request.serializingData().response
        
        try checkCancellation(response)
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
        logger.info("[\(functionName)] Server StatusCode: \(String(describing: response.response?.statusCode))")
//        logger.info("[\(functionName)] Server Response Value: \(String(describing: response.value))")
        
        // 디코딩 실패 시 원본 데이터 출력
        if response.value == nil, let data = response.data, let rawString = String(data: data, encoding: .utf8) {
            logger.info("[\(functionName)] 디코딩 실패 - Raw Data: \(rawString)")
            
            if let afError = response.error?.asAFError,
               case .responseSerializationFailed(let reason) = afError,
               case .decodingFailed(let underlyingError) = reason {
                logger.error("[\(functionName)] 에러 내용: \(String(describing: underlyingError))")
            }
        }
    }
    
    /// Alamofire 응답 중 취소 에러가 있는지 확인하고, 있다면 `CancellationError`를 던집니다.
    func checkCancellation<T>(_ response: DataResponse<T, AFError>) throws {
        if let error = response.error {
            // Alamofire 자체 취소 에러 (.explicitlyCancelled)
            if case .explicitlyCancelled = error {
                throw CancellationError()
            }
            // 내부 URLSession 취소 에러 (URLError.cancelled)
            if let urlError = error.underlyingError as? URLError, urlError.code == .cancelled {
                throw CancellationError()
            }
        }
    }
}
