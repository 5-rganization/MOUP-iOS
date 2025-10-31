//
//  WorkError.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

import Foundation

enum WorkError: LocalizedError, CustomDebugStringConvertible {
    case invalidVariableOrParameter // 400
    case invalidPermission // 403
    case notFound // 404
    case alreadyStarted // 409
    case invalidFieldValue // 422
}

extension WorkError {
    // 사용자 친화 에러 메시지
    var errorDescription: String? {
        switch self {
        case .invalidPermission: "해당 근무에 접근할 권한이 없습니다.\n다시 한번 확인해 주세요!"
        case .notFound: "해당하는 근무를 찾을 수 없어요.\n다시 한번 확인해 주세요!"
        case .alreadyStarted: "이미 근무중인 상태예요.\n다시 한번 확인해 주세요!"
        default: "오류가 발생하였습니다."
        }
    }

    // 디버깅용 에러 메시지
    var debugDescription: String {
        switch self {
        case .invalidVariableOrParameter: "works - 400, 유효하지 않은 경로/매개변수 (상세 내용은 응답 메세지 참고)"
        case .invalidPermission: "works - 403, 권한이 없는 접근"
        case .notFound: "works - 404, 요청한 정보를 찾을 수 없음 (상세 내용은 응답 메세지 참고)"
        case .alreadyStarted: "works - 409, 근무자가 이미 근무중인 상태"
        case .invalidFieldValue: "works - 422, 유효하지 않은 필드값 (상세 내용은 응답 메세지 참고)"
        }
    }
}
