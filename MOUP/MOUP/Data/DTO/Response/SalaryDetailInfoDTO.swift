//
//  SalaryDetailInfoDTO.swift
//  MOUP
//
//  Created by 양원식 on 12/8/25.
//

struct SalaryDetailInfoDTO: Codable {
    let salaryType: String
    let salaryCalculation: String
    
    /// 시급 혹은 금액
    let hourlyRate: Int?
    
    /// 월급날
    let salaryDate: Int?
    
    let hasNationalPension: Bool?
    let hasHealthInsurance: Bool?
    let hasEmploymentInsurance: Bool?
    let hasIndustrialAccident: Bool?
    let hasIncomeTax: Bool?
    let hasHolidayAllowance: Bool?
    let hasNightAllowance: Bool?
}
