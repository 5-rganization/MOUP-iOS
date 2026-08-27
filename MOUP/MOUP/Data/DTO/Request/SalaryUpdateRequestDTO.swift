//
//  SalaryUpdateRequestDTO.swift
//  MOUP
//
//  Created by 양원식 on 12/8/25.
//

/// 급여 수정 요청
///
/// 금액 필드 규칙은 `SalaryCreateRequest`와 같다 — `salaryCalculation`에 맞는 쪽만 채운다.
/// 서버가 `@AssertTrue`로 교차 검증하므로 어긋나면 422가 난다.
struct SalaryUpdateRequestDTO: Encodable {
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
