//
//  SignInRequestDTOs.swift
//  MOUP
//
//  Created by 송규섭 on 8/4/25.
//

import Foundation

/// 인증 관련(로그인, 회원가입 등) API 요청 시 필요한 모델들을 관리합니다.
struct SignInRequestDTO: Encodable {
    let provider: String
    let idToken: String
}

