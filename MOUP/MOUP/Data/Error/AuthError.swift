//
//  AuthError.swift
//  MOUP
//
//  Created by 송규섭 on 8/6/25.
//

import Foundation

enum AuthError: LocalizedError {
    case notMember // signIn, 404
}

extension AuthError {
    // 사용자 친화 에러 메시지
    var errorDescription: String? {
        switch self {
        case .notMember:
            "회원이 아닙니다. 회원 가입 화면으로 이동합니다."
        }
    }

    // 디버깅용 에러 메시지
    var debugDescription: String? {
        switch self {
        case .notMember:
            "signIn - 404, 회원이 아닌 유저입니다."
        }
    }
}
