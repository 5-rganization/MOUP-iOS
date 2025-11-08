//
//  RoutineRouter.swift
//  MOUP
//
//  Created by 송규섭 on 10/30/25.
//

import Foundation
import Alamofire

enum RoutineRouter {
    case fetchTodayRoutines
    case fetchWorkRoutines(workId: Int)
    case fetchAllRoutines
    case fetchRoutineDetail(routineId: Int)
    case createRoutine(request: CreateRoutineRequestDTO)
    case updateRoutine(routineId: Int, request: UpdateRoutineRequestDTO)
}

extension RoutineRouter: URLRequestConvertible {
    var baseURL: URL {
        guard let url = URL(string: NetworkConstants.baseURL) else {
            fatalError("Invalid base URL")
        }
        return url
    }

    var path: String {
        switch self {
        case .fetchTodayRoutines:
            return "/routines/today"
        case .fetchWorkRoutines(let workId):
            return "/routines/works/\(workId)/routines"
        case .fetchAllRoutines, .createRoutine:
            return "/routines"
        case .fetchRoutineDetail(let routineId):
            return "/routines/\(routineId)"
        case .updateRoutine(let routineId, _):
            return "/routines/\(routineId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchTodayRoutines, .fetchWorkRoutines, .fetchAllRoutines, .fetchRoutineDetail:
            return .get
        case .createRoutine:
            return .post
        case .updateRoutine:
            return .patch
        }
    }

    var requestBody: Encodable? {
        switch self {
        case .fetchTodayRoutines, .fetchWorkRoutines, .fetchAllRoutines, .fetchRoutineDetail:
            return nil
        case .createRoutine(let request):
            return request
        case .updateRoutine(_, let request):
            return request
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .fetchTodayRoutines, .fetchWorkRoutines, .fetchAllRoutines, .fetchRoutineDetail:
            return URLEncoding.default
        case .createRoutine, .updateRoutine:
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
