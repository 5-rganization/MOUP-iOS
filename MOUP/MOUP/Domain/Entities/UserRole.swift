//
//  UserRole.swift
//  MOUP
//
//  Created by 서동환 on 6/18/25.
//

/// 사용자 역할 Enum
/// - `worker`: 알바생
/// - `owner`: 사장님
enum UserRole: String, Decodable, CaseIterable {
    case owner = "ROLE_OWNER"
    case worker = "ROLE_WORKER"
    
    var displayStr: String {
        switch self {
        case .owner:
            return "사장님"
        case .worker:
            return "알바생"
        }
    }
}
