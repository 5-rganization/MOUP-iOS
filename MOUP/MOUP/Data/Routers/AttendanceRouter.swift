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
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchWorkerWorkplaceAttendanceHistory,
                .fetchOwnerWorkplaceAttendanceHistory:
            return .get
        }
    }

    var requestBody: Encodable? {
        switch self {
        case .fetchWorkerWorkplaceAttendanceHistory,
                .fetchOwnerWorkplaceAttendanceHistory:
            return nil
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .fetchWorkerWorkplaceAttendanceHistory,
                .fetchOwnerWorkplaceAttendanceHistory:
            return JSONEncoding.default
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        print("최종 url: \(url)")
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
