//
//  SignInRequestDTOs.swift
//  MOUP
//
//  Created by 송규섭 on 8/4/25.
//

import Foundation

/// 인증 관련(로그인, 회원가입 등) API 요청 시 필요한 모델들을 관리합니다.
struct LoginRequestDTO: Encodable {
    let provider: String
    let authCode: String
    let username: String // TODO: - 빈문자열로 플랫폼 분기. google의 경우 username 빈 문자열로.
}

/// 회원가입 API 요청 DTO
struct RegisterRequestDTO: Encodable {
    let nickname: String
    let role: String
}

/// 토큰 갱신 API 요청 DTO
struct refreshTokenRequestDTO: Encodable {
    let refreshToken: String
}
