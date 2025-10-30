//
//  WorkplaceCreateRequest.swift
//  MOUP
//
//  Created by 양원식 on 10/30/25.
//

// MARK: - WorkplaceCreateRequest
struct WorkplaceCreateRequest: Codable {
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
}
