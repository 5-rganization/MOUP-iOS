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
}

/// 회원가입 API 요청 DTO
struct RegisterRequestDTO: Encodable {
    let provider: String
    let authCode: String
    let username: String
    let nickname: String
    let role: String
}

/// 토큰 갱신 API 요청 DTO
struct refreshTokenRequestDTO: Encodable {
    let refreshToken: String
}
