//
//  WorkplaceError.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation

enum WorkplaceError: LocalizedError {
    case invalidRole // invite-codes, 403
    case notFound // invite-codes, 404
    case alreadyExists // invite-codes, 409
}

extension WorkplaceError {
    // 사용자 친화 에러 메시지
    var errorDescription: String? {
        switch self {
        case .invalidRole:
            return "해당 근무지에 접근할 권한이 없습니다."
        case .notFound:
            return "입력하신 초대 코드에 해당하는 근무지를 찾을 수 없습니다."
        case .alreadyExists:
            return "이미 가입된 근무자입니다."
        }
    }

    // 디버깅용 에러 메시지
    var debugDescription: String? {
        switch self {
        case .invalidRole:
            return "invite-codes - 403, 역할에 맞지 않는 접근"
        case .notFound:
            return "invite-codes - 404, 요청한 정보를 찾을 수 없음"
        case .alreadyExists:
            return "invite-codes - 409, 사용자가 이미 근무자로 존재"
        }
    }
}
