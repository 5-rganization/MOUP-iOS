//
//  UserIdentifier.swift
//  MOUP
//
//  Created by 송규섭 on 8/6/25.
//

import Foundation

struct User {
    let userId: Int64
    let role: UserRole
    let accessToken: String
    let refreshToken: String
}
