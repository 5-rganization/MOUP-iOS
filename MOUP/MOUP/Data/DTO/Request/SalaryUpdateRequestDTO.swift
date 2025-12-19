//
//  SalaryUpdateRequestDTO.swift
//  MOUP
//
//  Created by 양원식 on 12/8/25.
//

struct SalaryUpdateRequestDTO: Encodable {
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
