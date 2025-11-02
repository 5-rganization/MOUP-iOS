//
//  WorkplaceResponseDTOs.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation

struct InviteCodeWorkplaceResponseDTO: Decodable {
    let workplaceId: Int
    let workplaceName: String
    let categoryName: String
    let address: String?
    let latitude: Double?
    let longitude: Double?
}

/// 근무지 요약 정보 응답 DTO
struct WorkplaceSummaryResponseDTO: Decodable {
    let workplaceId: Int
    let workplaceName: String
    let isShared: Bool
}

/// 사장님의 근무지 초대 코드 조회에 대한 응답 DTO
struct InviteCodeResponseDTO: Decodable {
    let inviteCode: String
    let returnAlreadyExists: Bool?
}

extension WorkplaceSummaryResponseDTO {
    func toDomain() -> WorkplaceSummary {
        WorkplaceSummary(id: workplaceId, name: workplaceName, isShared: isShared)
    }

struct WorkplaceSummaryListResponseDTO: Decodable {
    let workplaceSummaryInfoList: [WorkplaceSummaryInfoDTO]
}
