//
//  UserProfile.swift
//  MOUP
//
//  Created by 신영 on 10/31/25.
//

import Foundation

struct UserProfile {
    let userId: Int
    let username: String
    let nickname: String
    let profileImageURL: String?
    let role: UserRole
    let createdAt: Date
}
