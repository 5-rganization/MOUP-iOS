//
//  InviteCodeWorkplace.swift
//  MOUP
//
//  Created by 송규섭 on 10/20/25.
//

import Foundation

/// 초대 코드를 기반으로 검색된 근무지 정보
struct InviteCodeWorkplace {
    let workplaceId: Int
    let workplaceName: String
    let categoryName: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
}
