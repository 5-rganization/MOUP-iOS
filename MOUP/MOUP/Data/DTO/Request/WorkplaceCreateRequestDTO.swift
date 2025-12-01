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
struct SalaryCreateRequest: Codable {
    let salaryType: String
    let salaryCalculation: String
    let hourlyRate: Int
    let salaryDate: Int
    let hasNationalPension: Bool
    let hasHealthInsurance: Bool
    let hasEmploymentInsurance: Bool
    let hasIndustrialAccident: Bool
    let hasIncomeTax: Bool
    let hasHolidayAllowance: Bool
    let hasNightAllowance: Bool

    // 클라이언트용 생성자 추가
    init(
        salaryType: String,
        salaryCalculation: String,
        hourlyRate: Int,
        salaryDate: Int,
        hasNationalPension: Bool,
        hasHealthInsurance: Bool,
        hasEmploymentInsurance: Bool,
        hasIndustrialAccident: Bool,
        hasIncomeTax: Bool,
        hasHolidayAllowance: Bool,
        hasNightAllowance: Bool
    ) {
        self.salaryType = salaryType
        self.salaryCalculation = salaryCalculation
        self.hourlyRate = hourlyRate
        self.salaryDate = salaryDate
        self.hasNationalPension = hasNationalPension
        self.hasHealthInsurance = hasHealthInsurance
        self.hasEmploymentInsurance = hasEmploymentInsurance
        self.hasIndustrialAccident = hasIndustrialAccident
        self.hasIncomeTax = hasIncomeTax
        self.hasHolidayAllowance = hasHolidayAllowance
        self.hasNightAllowance = hasNightAllowance
    }
}
