//
//  UpdateWorkplaceRequestDTO.swift
//  MOUP
//
//  Created by 양원식 on 12/8/25.
//

import Foundation

/// 근무지 수정 요청 DTO
///
/// 서버는 이 요청을 부분 갱신(PATCH)으로 처리한다. **키가 빠진 필드는 기존 값을 유지하고,
/// 키가 실린 필드만 덮어쓴다.** 그래서 화면에서 건드리지 않는 필드는 `nil`로 두어 키 자체를
/// 빼야 한다 — 더미값을 채워 보내면 서버에 저장된 실제 값이 그 더미로 밀린다.
///
/// `Encodable` 합성 구현이 옵셔널을 `encodeIfPresent`로 인코딩하므로, `nil`이면 키가 빠진다.
struct UpdateWorkplaceRequestDTO: Encodable {
    let workplaceName: String
    let categoryName: String

    // 화면에 입력 수단이 없다. 서버에 저장된 값을 그대로 두기 위해 항상 nil로 보낸다.
    let address: String?
    let latitude: Double?
    let longitude: Double?

    // 둘 중 하나만 사용됨 (owner 또는 worker)
    let ownerBasedLabelColor: String?
    let workerBasedLabelColor: String?

    // 알바일 때만 필요
    let salaryUpdateRequest: SalaryUpdateRequestDTO?

    init(
        workplaceName: String,
        categoryName: String,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
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
