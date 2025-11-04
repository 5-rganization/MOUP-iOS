//
//  AuthError.swift
//  MOUP
//
//  Created by 송규섭 on 8/6/25.
//

import Foundation

enum AuthError: LocalizedError {
    case notMember // login·register·refreshToken, 404
    case invalidUserName // register, 422
    case invalidToken // refreshToken, 400
    case deletedUser // refreshToken, 409
    case alreadySignUp // register, 409
}

extension AuthError {
    // 사용자 친화 에러 메시지
    var errorDescription: String? {
        switch self {
        case .notMember:
            return "회원이 아닙니다.\n회원 가입 화면으로 이동합니다."
        case .invalidUserName:
            return "닉네임이 올바르지 않습니다.\n특수문자 제외 8자 이하로 입력해주세요."
        case .invalidToken:
            return "로그인 정보가 만료되었습니다.\n다시 로그인해주세요."
        case .deletedUser:
            return "탈퇴 처리된 계정입니다.\n신규 회원으로 가입해주세요."
        case .alreadySignUp:
            return "이미 회원가입이 완료된 유저입니다.\n로그인해주세요."
        }
    }

    // 디버깅용 에러 메시지
    var debugDescription: String? {
        switch self {
        case .notMember:
            "login - 201·202, 회원이 아닌 유저"
        case .invalidUserName:
            "register - 422, 잘못된 유저 이름"
        case .invalidToken:
            "refreshToken - 400, 유효하지 않은 토큰"
        case .deletedUser:
            "refreshToken - 409, 삭제된 유저"
        case .alreadySignUp:
            "register - 409, 이미 회원가입이 완료된 유저"
        }
    }
}
