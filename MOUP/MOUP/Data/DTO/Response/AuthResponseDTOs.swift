//
//  AuthResponseDTOs.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

/// 인증 관련(로그인, 회원가입 등) API 호출 결과 관련 모델들을 관리합니다.
struct LoginResponseDTO: Decodable {
    let role: String?
    let accessToken: String
    let refreshToken: String
}

/// 회원가입 API 응답 DTO
struct RegisterResponseDTO: Decodable {
    let role: String
}

/// 토큰 갱신 API 응답 DTO
struct RefreshTokenResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}

