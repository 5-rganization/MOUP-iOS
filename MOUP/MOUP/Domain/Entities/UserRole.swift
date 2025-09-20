//
//  UserRole.swift
//  MOUP
//
//  Created by 서동환 on 6/18/25.
//

/// 사용자 역할 Enum
/// - `worker`: 알바생
/// - `owner`: 사장님
enum UserRole: String, Decodable {
    case worker = "ROLE_WORKER"
    case owner = "ROLE_OWNER"
}
