//
//  AttendanceError.swift
//  MOUP
//
//  Created by 송규섭 on 11/4/25.
//

import Foundation

enum AttendanceError: LocalizedError {
    case invalidRequest // 400, Worker·Owner 근태 조회
    case unauthorizedAccess // 403, Worker·Owner 근태 조회
    case notFound // 404, Worker·Owner 근태 조회
}

extension AttendanceError {
    // 사용자 친화 에러 메시지
    var errorDescription: String? {
        switch self {
        case .invalidRequest, .unauthorizedAccess:
            "요청을 처리할 수 없습니다. 잠시 후 다시 시도해주세요."
        case .notFound:
            "요청하신 정보를 찾지 못했어요. 잠시 후 다시 시도해주세요."
        }
    }

    // 디버깅용 에러 메시지
    var debugDescription: String? { // 두 역할에 대한 요청을 겸하기 때문에 특정 api 언급 X
        switch self {
        case .invalidRequest:
            "근무 내역 조회 - 400"
        case .unauthorizedAccess:
            "근무 내역 조회 - 403"
        case .notFound:
            "근무 내역 조회 - 404"
        }
    }
}
