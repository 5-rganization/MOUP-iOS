//
//  WorkplaceJoinRequestDTO.swift
//  MOUP
//
//  Created by 양원식 on 11/15/25.
//


struct WorkplaceJoinRequestDTO: Encodable {
    let inviteCode: String
    let workerBasedLabelColor: String
    let salaryCreateRequest: SalaryJoinCreateRequest
}

struct SalaryJoinCreateRequest: Encodable {
    let salaryType: String
    let salaryCalculation: String
    let hourlyRate: Int?
    let fixedRate: Int?
    let salaryDate: Int?
    let salaryDay: String?
    let hasNationalPension: Bool
    let hasHealthInsurance: Bool
    let hasEmploymentInsurance: Bool
    let hasIndustrialAccident: Bool
    let hasIncomeTax: Bool
    let hasHolidayAllowance: Bool
    let hasNightAllowance: Bool
}
