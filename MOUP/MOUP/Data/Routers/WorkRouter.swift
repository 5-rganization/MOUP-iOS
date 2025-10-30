//
//  WorkRouter.swift
//  MOUP
//
//  Created by 서동환 on 10/28/25.
//

import OSLog

import Alamofire

/// 근무 관련 엔드포인트 라우터
///
/// - `createMyWork` (POST /workplaces/{id}/workers/me/works): 근무지(매장)에 사용자 근무 생성
/// - `createWorkerWork` (POST /workplaces/{id}/workers/{id}/works): 근무자에게 근무 생성 (사장님 전용)
///
/// - `fetchWorkDetail` (GET /works/{id}?view=detail): 근무 상세 조회
/// - `fetchWorkSummary` (GET /works/{id}?view=summary): 근무 요약 조회
/// - `fetchAllMyWorkList` (GET /works): 사용자의 모든 근무 범위 조회
///   - `baseYearMonth` 형식: `yyyy-MM`
/// - `fetchWorkplaceMyWorkList` (GET /workplaces/{id}/workers/me/works): 특정 근무지(매장)에서 사용자 근무 범위 조회
///   - `baseYearMonth` 형식: `yyyy-MM`
/// - `fetchWorkplaceAllWorkList` (GET /workplaces/{id}/works): 특정 근무지(매장)의 모든 근무 범위 조회
///   - `baseYearMonth` 형식: `yyyy-MM`
///
/// - `updateMyWork` (PATCH /works/{id}): 사용자 근무 업데이트
/// - `updateWorkerWork` (PATCH /workplaces/{id}/workers/{id}/works/{id}): 근무자 근무 업데이트 (사장님 전용)
///
/// - `deleteWork` (DELETE /works/{id}): 근무 삭제
/// - `deleteRecurringWork` (DELETE /works/recurring/{id}): 반복 근무 삭제
///
/// - `startWork` (POST /workplaces/{id}/workers/me/works/start): 근무 출근 (알바생 전용)
/// - `endWork` (PATCH /workplaces/{id}/workers/me/works/end): 근무 퇴근 (알바생 전용)
///
enum WorkRouter {
    case createMyWork(workplaceId: Int, dto: MyWorkCreateRequestDTO)
    case createWorkerWork(workplaceId: Int, workerId: Int, dto: WorkerWorkCreateRequestDTO)
    
    case fetchWork(workId: Int, viewQueryType: ViewQuery)
    case fetchAllMyWorkList(baseYearMonth: String)
    case fetchWorkplaceMyWorkList(workplaceId: Int, baseYearMonth: String)
    case fetchWorkplaceAllWorkList(workplaceId: Int, baseYearMonth: String)
    
    case updateMyWork(workId: Int, dto: MyWorkUpdateRequestDTO)
    case updateWorkerWork(workplaceId: Int, workerId: Int, workId: Int, dto: WorkerWorkUpdateRequestDTO)
    
    case deleteWork(workId: Int)
    case deleteRecurringWork(workId: Int)
    
    case startWork(workplaceId: Int)
    case endWork(workplaceId: Int)
}

extension WorkRouter: URLRequestConvertible {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "WorkRouter")
    
    var baseURL: URL {
        guard let url = URL(string: NetworkConstants.baseURL) else { fatalError("Invalid base URL") }
        return url
    }
    
    var path: String {
        switch self {
        case .createMyWork(let workplaceId, _):
            return "/workplaces/\(workplaceId)/workers/me/works"
        case .createWorkerWork(let workplaceId, let workerId, _):
            return "/workplaces/\(workplaceId)/workers/\(workerId)/works"
            
        case .fetchWork(let workId, _):
            return "/works/\(workId)"
        case .fetchAllMyWorkList:
            return "/works"
        case .fetchWorkplaceMyWorkList(let workplaceId, _):
            return "/workplaces/\(workplaceId)/workers/me/works"
        case .fetchWorkplaceAllWorkList(let workplaceId, _):
            return "/workplaces/\(workplaceId)/works"
            
        case .updateMyWork(let workId, _):
            return "/works/\(workId)"
        case .updateWorkerWork(let workplaceId, let workerId, let workId, _):
            return "/workplaces/\(workplaceId)/workers/\(workerId)/works/\(workId)"
            
        case .deleteWork(let workId):
            return "/works/\(workId)"
        case .deleteRecurringWork(let workId):
            return "/works/recurring/\(workId)"
            
        case .startWork(let workplaceId):
            return "/workplaces/\(workplaceId)/workers/me/works/start"
        case .endWork(let workplaceId):
            return "/workplaces/\(workplaceId)/workers/me/works/end"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createMyWork, .createWorkerWork, .startWork:
            return .post
        case .fetchWork, .fetchAllMyWorkList, .fetchWorkplaceMyWorkList, .fetchWorkplaceAllWorkList:
            return .get
        case .updateMyWork, .updateWorkerWork, .endWork:
            return .patch
        case .deleteWork, .deleteRecurringWork:
            return .delete
        }
    }
    
    var requestBody: Encodable? {
        switch self {
        case .createMyWork(_, let dto):
            return dto
        case .createWorkerWork(_, _, let dto):
            return dto
            
        case .updateMyWork(_, let dto):
            return dto
        case .updateWorkerWork(_, _, _, let dto):
            return dto
            
        case .fetchWork, .fetchAllMyWorkList, .fetchWorkplaceMyWorkList, .fetchWorkplaceAllWorkList,
                .deleteWork, .deleteRecurringWork,
                .startWork, .endWork:
            return nil
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchWork(_, let viewQueryType):
            return ["view": viewQueryType.rawValue]
        case .fetchAllMyWorkList(let baseYearMonth), .fetchWorkplaceMyWorkList(_, let baseYearMonth), .fetchWorkplaceAllWorkList(_, let baseYearMonth):
            return ["baseYearMonth": baseYearMonth]
        default:
            return nil
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        Self.logger.info("최종 url: \(url)")
        var request = try URLRequest(url: url, method: method)
        
        if let requestBody {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(requestBody)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let httpBody = request.httpBody {
                Self.logger.info("Request body: \(String(data: httpBody, encoding: .utf8) ?? "")")
            }
        }
        
        if let parameters {
            request = try URLEncoding.default.encode(request, with: parameters)
        }
        
        return request
    }
}
