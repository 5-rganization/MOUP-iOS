//
//  AuthError.swift
//  MOUP
//
//  Created by 송규섭 on 8/6/25.
//

import Foundation

enum AuthError: LocalizedError {
    case notMember // login, 404
    case invalidUserName // register, 400
}

extension AuthError {
    // 사용자 친화 에러 메시지
    var errorDescription: String? {
        switch self {
        case .notMember:
            return "회원이 아닙니다. 회원 가입 화면으로 이동합니다."
        case .invalidUserName:
            return "닉네임이 올바르지 않습니다. 특수문자 제외 8자 이하로 입력해주세요."
        }
    }

    // 디버깅용 에러 메시지
    var debugDescription: String? {
        switch self {
        case .notMember:
            "login - 201·202, 회원이 아닌 유저"
        case .invalidUserName:
            "register - 400, 잘못된 유저 이름"
        }
    }
}
