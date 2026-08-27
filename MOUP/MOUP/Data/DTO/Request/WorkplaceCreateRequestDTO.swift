//
//  WorkplaceCreateRequestDTO.swift
//  MOUP
//
//  Created by 양원식 on 10/30/25.
//

// MARK: - WorkplaceCreateRequest
struct WorkplaceCreateRequestDTO: Codable {
    let workplaceName: String
    let categoryName: String
    let address: String
    let latitude: Double
    let longitude: Double
    let workerBasedLabelColor: String
    let salaryCreateRequest: SalaryCreateRequest
}

// MARK: - SalaryCreateRequest

/// 급여 등록 요청
///
/// 서버는 `salaryCalculation`에 맞는 금액 필드가 채워졌는지를 교차 검증한다
/// (`SalaryCreateRequest.isRateConsistentWithCalculation`). 시급제면 `hourlyRate`,
/// 고정급제면 `fixedRate`가 있어야 하고, 어긋나면 422로 거절된다.
/// **둘 중 해당하는 하나만 채우고 나머지는 nil로 둔다.**
struct SalaryCreateRequest: Codable {
    let salaryType: String
    let salaryCalculation: String
    let hourlyRate: Int?
    let fixedRate: Int?
    let salaryDate: Int
    let hasNationalPension: Bool
    let hasHealthInsurance: Bool
    let hasEmploymentInsurance: Bool
    let hasIndustrialAccident: Bool
    let hasIncomeTax: Bool
    let hasHolidayAllowance: Bool
    let hasNightAllowance: Bool
}
