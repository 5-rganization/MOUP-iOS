//
//  HomeRouter.swift
//  MOUP
//
//  Created by 송규섭 on 10/26/25.
//

import Foundation
import Alamofire

enum HomeRouter {
    case fetchHomeData
}

extension HomeRouter: URLRequestConvertible {
    var baseURL: URL {
        guard let url = URL(string: NetworkConstants.baseURL) else {
            fatalError("Invalid base URL")
        }
        return url
    }

    var path: String {
        switch self {
        case .fetchHomeData:
            return "/home"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchHomeData:
            return .get
        }
    }

    var requestBody: Encodable? {
        switch self {
        case .fetchHomeData:
            return nil
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .fetchHomeData:
            return URLEncoding.default
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
