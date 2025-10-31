//
//  WorkplaceRequestDTOs.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation

/// 근무지 내 초대 코드 생성 시 필요한 DTO
struct InviteCodeRequestDTO: Encodable {
    let forceGenerate: Bool
}
