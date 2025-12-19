//
//  UpdateWorkplaceRequestDTO.swift
//  MOUP
//
//  Created by 양원식 on 12/8/25.
//

import Foundation

struct UpdateWorkplaceRequestDTO: Encodable {
    let workplaceName: String
    let categoryName: String
    let address: String
    let latitude: Double
    let longitude: Double

    // 둘 중 하나만 사용됨 (owner 또는 worker)
    let ownerBasedLabelColor: String?
    let workerBasedLabelColor: String?

    // 알바일 때만 필요
    let salaryUpdateRequest: SalaryUpdateRequestDTO?

    init(
        workplaceName: String,
        categoryName: String,
        address: String,
        latitude: Double,
        longitude: Double,
        ownerBasedLabelColor: String? = nil,
        workerBasedLabelColor: String? = nil,
        salaryUpdateRequest: SalaryUpdateRequestDTO? = nil
    ) {
        self.workplaceName = workplaceName
        self.categoryName = categoryName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.ownerBasedLabelColor = ownerBasedLabelColor
        self.workerBasedLabelColor = workerBasedLabelColor
        self.salaryUpdateRequest = salaryUpdateRequest
    }
}
