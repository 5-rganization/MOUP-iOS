//
//  InviteCodeInfo.swift
//  MOUP
//
//  Created by 송규섭 on 10/31/25.
//

import Foundation

/// 초대 코드에 대한 도메인 모델
struct InviteCodeInfo {
    let inviteCode: String
    let returnAlreadyExists: Bool?
}
