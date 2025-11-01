//
//  UserResponseDTOs.swift
//  MOUP
//
//  Created by 신영 on 10/31/25.
//

import Foundation

struct UserProfileResponseDTO: Decodable {
    let userId: Int
    let username: String
    let nickname: String
    let profileImg: String?
    let role: String
    let createdAt: String
}

struct UpdateNicknameResponseDTO: Decodable {
    let userId: Int
    let nickname: String
}
