//
//  SignInResult.swift
//  MOUP
//
//  Created by 송규섭 on 10/10/25.
//

import Foundation

enum SignInResult {
    case signIn(User) // 로그인 성공 시
    case needsSignUp(accessToken: String, refreshToken: String) // 로그인은 했으나 회원이 아니어서 회원가입이 요구될 시
}
