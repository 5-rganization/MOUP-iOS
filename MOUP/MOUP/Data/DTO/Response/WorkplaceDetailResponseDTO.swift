//
//  WorkplaceDetailResponseDTO.swift
//  MOUP
//
//  Created by 양원식 on 12/8/25.
//

import Foundation

struct WorkplaceDetailResponseDTO: Codable {
    let workplaceName: String
    let categoryName: String
    
    let address: String?
    let latitude: Double?
    let longitude: Double?
    
    /// 사장님일 경우만 존재
    let ownerBasedLabelColor: String?
    
    /// 알바생일 경우만 존재
    let workerBasedLabelColor: String?
    
    /// 알바생일 경우만 존재
    let salaryDetailInfo: SalaryDetailInfoDTO?
}
