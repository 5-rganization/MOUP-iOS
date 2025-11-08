//
//  GoogleAuthRouter.swift
//  MOUP
//
//  Created by 송규섭 on 7/27/25.
//

import Foundation
import Alamofire

enum AttendanceRouter {
    case fetchWorkerWorkplaceAttendanceHistory(workplaceId: Int)
    case fetchOwnerWorkplaceAttendanceHistory(workplaceId: Int, workerId: Int)
    case fetchWorkplaceWorkers(workplaceId: Int, isActiveOnly: Bool)
    case startWork(workplaceId: Int)
    case endWork(workplaceId: Int)
}

extension AttendanceRouter: URLRequestConvertible {
    var baseURL: URL {
        guard let url = URL(string: NetworkConstants.baseURL) else {
            fatalError("Invalid base URL")
        }
        return url
    }

    var path: String {
        switch self {
        case .fetchWorkerWorkplaceAttendanceHistory(let workplaceId):
            return "/workplaces/\(workplaceId)/workers/me"
        case .fetchOwnerWorkplaceAttendanceHistory(let workplaceId, let workerId):
            return "/workplaces/\(workplaceId)/workers/\(workerId)"
        case .fetchWorkplaceWorkers(let workplaceId, _):
            return "/workplaces/\(workplaceId)/workers"
        case .startWork(let workplaceId):
            return "/workplaces/\(workplaceId)/workers/me/works/start"
        case .endWork(let workplaceId):
            return "/workplaces/\(workplaceId)/workers/me/works/end"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchWorkerWorkplaceAttendanceHistory,
                .fetchOwnerWorkplaceAttendanceHistory,
                .fetchWorkplaceWorkers:
            return .get
        case .startWork:
            return .post
        case .endWork:
            return .patch
        }
    }

    var requestBody: Encodable? {
        switch self {
        case .fetchWorkerWorkplaceAttendanceHistory,
                .fetchOwnerWorkplaceAttendanceHistory,
                .fetchWorkplaceWorkers,
                .startWork,
                .endWork:
            return nil
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .fetchWorkerWorkplaceAttendanceHistory,
                .fetchOwnerWorkplaceAttendanceHistory,
                .fetchWorkplaceWorkers,
                .startWork,
                .endWork:
            return URLEncoding.default
        }
    }

    func asURLRequest() throws -> URLRequest {
        var url = baseURL.appendingPathComponent(path)
        print("최종 url: \(url)")

        switch self {
        case .fetchWorkplaceWorkers(_, let isActiveOnly):
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "isActiveOnly", value: "\(isActiveOnly)")
            ]
            if let newURL = components?.url {
                url = newURL
            }
        default:
            break
        }
        
        var request = try URLRequest(url: url, method: method)
        
        if let body = requestBody {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            if let httpBody = request.httpBody {
                print("Request body: \(String(data: httpBody, encoding: .utf8) ?? "")")
            }
        }

        return request
    }
}
