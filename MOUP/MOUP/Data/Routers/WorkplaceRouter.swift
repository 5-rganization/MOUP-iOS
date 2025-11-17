//
//  WorkplaceRouter.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation
import Alamofire

enum WorkplaceRouter {
    case fetchWorkplaceList(isSharedOnly: Bool)
    case fetchWorkplaceByInviteCode(inviteCode: String)
    case fetchInviteCode(workplaceId: Int, requestDTO: InviteCodeRequestDTO)
    case createWorkplace(request: WorkplaceCreateRequestDTO)
    case createOwnerWorkplace(request: OwnerWorkplaceCreateRequestDTO)
    case joinWorkplace(request: WorkplaceJoinRequestDTO)
    case deleteWorkplace(workplaceId: Int)
}

extension WorkplaceRouter: URLRequestConvertible {
    var baseURL: URL {
        guard let url = URL(string: NetworkConstants.baseURL) else {
            fatalError("Invalid base URL")
        }
        return url
    }

    var path: String {
        switch self {
        case .fetchWorkplaceList:
            return "/workplaces"
        case .fetchWorkplaceByInviteCode(let inviteCode):
            return "/workplaces/invite-codes/\(inviteCode)"
        case .fetchInviteCode(let workplaceId, _):
            return "/workplaces/\(workplaceId)/invite-code"
        case .createWorkplace:
            return "/workplaces"
        case .createOwnerWorkplace:
            return "/workplaces"
        case .joinWorkplace:
            return "/workplaces/join"
        case .deleteWorkplace(let workplaceId):
            return "/workplaces/\(workplaceId)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchWorkplaceList, .fetchWorkplaceByInviteCode:
            return .get
        case .fetchInviteCode:
            return .put
        case .createWorkplace, .createOwnerWorkplace, .joinWorkplace:
            return .post
        case .deleteWorkplace:
            return .delete
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchWorkplaceList(let isSharedOnly):
            return ["isSharedOnly": isSharedOnly]
        case .createWorkplace, .createOwnerWorkplace, .fetchWorkplaceByInviteCode, .fetchInviteCode, .joinWorkplace, .deleteWorkplace:
            return nil
        }
    }

    var requestBody: Encodable? {
        switch self {
        case .fetchWorkplaceList, .fetchWorkplaceByInviteCode, .deleteWorkplace:
            return nil
        case .fetchInviteCode(_, let requestDTO):
            return requestDTO
        case .createWorkplace(let request):
            return request
        case .createOwnerWorkplace(let request):
            return request
        case .joinWorkplace(let request):
            return request
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .fetchWorkplaceList, .fetchWorkplaceByInviteCode, .deleteWorkplace:
            return URLEncoding.default
        case .createWorkplace, .createOwnerWorkplace, .fetchInviteCode, .joinWorkplace:
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
        
        if let parameters {
            request = try URLEncoding.default.encode(request, with: parameters)
        }

        return request
    }
}
