//
//  SalaryDetailInfoDTO.swift
//  MOUP
//
//  Created by 양원식 on 12/8/25.
//

struct SalaryDetailInfoDTO: Codable {
    let salaryType: String
    let salaryCalculation: String
    
    /// 시급 (`salaryCalculation`이 시급제일 때만 채워진다)
    let hourlyRate: Int?

    /// 고정급 (`salaryCalculation`이 고정급제일 때만 채워진다)
    ///
    /// "월급 총액"이 아니라 **한 지급 주기의 금액**이다. 서버는 `salaryType`에 따라
    /// 매월이면 그대로, 매주면 그 달의 주급 지급 횟수만큼, 매일이면 근무일 수만큼 곱한다.
    let fixedRate: Int?
    
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
